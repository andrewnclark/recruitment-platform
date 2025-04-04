defmodule Recruitment.Workers.CVSummarizationWorker do
  @moduledoc """
  Oban worker for processing CV/resume summarization in the background.
  
  This worker is responsible for extracting the text from a resume file,
  sending it to the CV summarization service, and updating the application
  record with the generated summary.
  """

  use Oban.Worker, 
    queue: :cv_processing, 
    max_attempts: 3,
    priority: 3

  alias Recruitment.Applications
  alias Recruitment.Applications.Application
  alias Recruitment.AI.CVSummarizer
  alias Recruitment.Repo
  alias Phoenix.PubSub
  
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"application_id" => application_id}}) do
    # Get the application with the CV
    application = Applications.get_application!(application_id)
    
    # Extract text from the resume
    # In a real implementation, this would involve accessing the actual file,
    # parsing its content based on format (PDF, DOC, etc.), and extracting text
    case extract_resume_text(application) do
      {:ok, resume_text} ->
        # Update the application with "processing" status
        {:ok, updated_app} = Applications.update_application(application, %{summary_status: "processing"})
        
        # Broadcast the status update
        broadcast_update(updated_app)
        
        # Generate summary
        case CVSummarizer.summarize(resume_text) do
          {:ok, summary} ->
            # Update the application with the summary
            {:ok, updated_app} = Applications.update_application(application, %{
              cv_summary: summary,
              summary_status: "completed"
            })
            
            # Broadcast the completion with the summary
            broadcast_update(updated_app)
            
            Logger.info("Successfully generated CV summary for application ##{application_id}")
            :ok
            
          {:error, reason} ->
            # Update application with error status
            {:ok, updated_app} = Applications.update_application(application, %{summary_status: "error"})
            
            # Broadcast the error status
            broadcast_update(updated_app)
            
            Logger.error("Failed to generate CV summary for application ##{application_id}: #{reason}")
            {:error, reason}
        end
        
      {:error, reason} ->
        {:ok, updated_app} = Applications.update_application(application, %{summary_status: "error"})
        
        # Broadcast the error status
        broadcast_update(updated_app)
        
        Logger.error("Failed to extract text from resume for application ##{application_id}: #{reason}")
        {:error, reason}
    end
  end
  
  @doc """
  Broadcasts application updates to all subscribed LiveViews.
  """
  def broadcast_update(%Application{} = application) do
    PubSub.broadcast(
      Recruitment.PubSub,
      "application:#{application.id}",
      {:cv_summary_updated, application}
    )
  end
  
  @doc """
  Extracts text content from an applicant's resume.
  
  In a production environment, this would involve file access and parsing
  based on file format (PDF, DOC, TXT, etc.).
  
  ## Parameters
    - application: The application record containing the resume file path
  
  ## Returns
    - {:ok, text} - Successfully extracted text
    - {:error, reason} - Error occurred during extraction
  """
  def extract_resume_text(%Application{resume: resume_path}) when is_binary(resume_path) do
    # In a real implementation, you would:
    # 1. Find the actual file (maybe from a storage service like S3)
    # 2. Determine the file type (PDF, DOC, etc.)
    # 3. Use the appropriate library to extract text
    #
    # For now, we'll return mock data for development purposes
    
    # Mock a successful text extraction
    text = """
    JOHN DOE
    Software Engineer
    
    EXPERIENCE
    Senior Developer at Tech Company (2020-Present)
    - Led development of cloud-based applications
    - Implemented CI/CD pipelines for automated testing
    - Mentored junior developers
    
    Software Engineer at Startup Inc. (2018-2020)
    - Developed RESTful APIs using Elixir/Phoenix
    - Built responsive web interfaces with React
    
    SKILLS
    - Programming: Elixir, JavaScript, Python, SQL
    - Frameworks: Phoenix, React, Django
    - Tools: Git, Docker, AWS
    
    EDUCATION
    Bachelor of Science in Computer Science
    University of Technology (2014-2018)
    """
    
    {:ok, text}
  end
  
  def extract_resume_text(_application) do
    {:error, "No resume file found"}
  end
end
