defmodule Recruitment.AI.CVSummarizer do
  @moduledoc """
  Service module for summarizing CV/resume content using Bumblebee.
  
  This module uses the Bumblebee library to generate a concise summary
  of an applicant's resume, highlighting key skills, experiences, and
  qualifications relevant to the job application.
  """

  alias Nx.Serving
  require Logger

  @doc """
  Initializes the summarization model.
  This function loads the model into memory on application startup.
  """
  def init do
    case create_summarization_serving() do
      {:ok, serving} ->
        # Store the serving in the application env for later use
        Application.put_env(:recruitment, :summarization_serving, serving)
        Logger.info("CV summarization model initialized successfully")
        :ok
      {:error, reason} ->
        Logger.error("Failed to initialize CV summarization model: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Creates a summarization serving using Bumblebee with the 
  facebook/bart-large-cnn model.
  
  This model is specifically trained for text summarization tasks.
  """
  def create_summarization_serving do
    try do
      # Use Nx defn compilation to improve performance
      Nx.Defn.global_default_options(compiler: EXLA)
      
      # Load the pre-trained BART model for summarization
      {:ok, model_info} = Bumblebee.load_model({:hf, "facebook/bart-large-cnn"})
      {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "facebook/bart-large-cnn"})
      
      # Create a summarization serving
      serving = Bumblebee.Text.generation(model_info, tokenizer,
        min_length: 50,
        max_length: 150,
        # For summarization tasks, beam search often produces better results
        strategy: %{type: :beam_search, num_beams: 4},
        # Adjust for summarization rather than open-ended generation
        top_k: 50,
        top_p: 0.95,
        # Ensure we don't repeat content too much
        no_repeat_ngram_size: 3
      )
      
      {:ok, serving}
    rescue
      e ->
        Logger.error("Error creating summarization serving: #{inspect(e)}")
        
        # In development or test environments, we'll use a mock serving
        if Mix.env() in [:dev, :test] do
          Logger.warn("Using mock summarization serving in #{Mix.env()} environment")
          {:ok, :mock_summarization_serving}
        else
          {:error, "Failed to load summarization model: #{inspect(e)}"}
        end
    end
  end

  @doc """
  Summarizes a CV/resume content.
  
  Extracts key information from the provided resume text and
  generates a concise summary highlighting relevant skills and experience.
  
  ## Parameters
    - resume_text: The text content of the resume to summarize
    
  ## Returns
    - {:ok, summary} - Successfully generated summary
    - {:error, reason} - Error occurred during summarization
  """
  def summarize(resume_text) when is_binary(resume_text) do
    if String.trim(resume_text) == "" do
      {:error, "Resume text is empty"}
    else
      try do
        # Get the serving from application env
        serving = Application.get_env(:recruitment, :summarization_serving)
        
        # If we're using a real serving, run the model
        if serving != :mock_summarization_serving do
          # For summarization, we want to prompt the model with the task
          input_text = "Summarize this resume: #{resume_text}"
          
          # Run the model through the serving
          %{results: [%{text: summary}]} = Nx.Serving.run(serving, input_text)
          
          # Clean up the summary - remove any incomplete sentences
          clean_summary = cleanup_summary(summary)
          
          {:ok, clean_summary}
        else
          # Fall back to mock implementation if no real model is available
          {:ok, generate_mock_summary(resume_text)}
        end
      rescue
        e ->
          Logger.error("Error summarizing resume: #{inspect(e)}")
          
          # In non-production environments, fall back to mock
          if Mix.env() in [:dev, :test] do
            Logger.warn("Falling back to mock summary in #{Mix.env()} environment")
            {:ok, generate_mock_summary(resume_text)}
          else
            {:error, "Failed to summarize resume: #{inspect(e)}"}
          end
      end
    end
  end
  
  @doc """
  Cleans up the summary text to ensure it's properly formatted.
  
  Sometimes model outputs can have incomplete sentences or other issues.
  This function cleans that up.
  
  ## Parameters
    - summary: The raw summary text from the model
  """
  def cleanup_summary(summary) when is_binary(summary) do
    # Remove any trailing incomplete sentences
    # We'll consider a sentence complete if it ends with ., !, or ?
    case Regex.run(~r/^(.*?[.!?])\s+[^.!?]*$/, summary) do
      [_, complete_part] -> complete_part
      nil -> summary
    end
    |> String.trim()
  end
  
  @doc """
  Mock implementation of CV summarization for development.
  
  This function extracts keywords from the resume text and creates
  a simple summary. It will be used as a fallback when the Bumblebee model
  is not available or during testing.
  
  ## Parameters
    - resume_text: The text content of the resume to summarize
  """
  def generate_mock_summary(resume_text) do
    # Extract key sections and keywords from resume
    experience_keywords = extract_keywords(resume_text, ["experience", "work", "job", "position"])
    skills_keywords = extract_keywords(resume_text, ["skill", "technology", "programming", "language"])
    education_keywords = extract_keywords(resume_text, ["education", "university", "college", "degree"])
    
    # Generate a simple summary
    """
    ## Professional Summary
    
    The candidate appears to have experience in #{Enum.join(Enum.take(experience_keywords, 3), ", ")}.
    
    ## Skills
    
    Key skills include #{Enum.join(Enum.take(skills_keywords, 5), ", ")}.
    
    ## Education
    
    Education background includes #{Enum.join(Enum.take(education_keywords, 2), ", ")}.
    
    This is an AI-generated summary and may not capture all details from the resume.
    """
  end
  
  @doc """
  Helper function to extract keywords from resume text.
  
  ## Parameters
    - text: The text to extract keywords from
    - contexts: List of context words to look for
  """
  defp extract_keywords(text, contexts) do
    # Split text into words and normalize
    words = 
      text
      |> String.downcase()
      |> String.split(~r/\W+/, trim: true)
      |> Enum.filter(&(String.length(&1) > 3))
      |> Enum.uniq()
    
    # Find words that appear near context words
    # This is a very simplistic approach
    Enum.filter(words, fn word ->
      Enum.any?(contexts, &String.contains?(text, &1 <> " " <> word))
    end)
    |> Enum.take(10)
    |> Enum.map(&String.capitalize/1)
  end
end
