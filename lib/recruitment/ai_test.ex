defmodule Recruitment.AITest do
  @moduledoc """
  This module contains helper functions for testing the CV summarization feature.
  These are intended for development and testing purposes only.
  """
  
  alias Recruitment.Applications
  alias Recruitment.Applications.Application
  alias Recruitment.Repo
  
  @doc """
  Test function to trigger CV summarization for an application.
  
  ## Parameters
    - application_id: The ID of the application to summarize
  """
  def test_cv_summarization(application_id) do
    IO.puts("Testing CV summarization for application ##{application_id}")
    
    # Get the application
    case Repo.get(Application, application_id) do
      nil ->
        IO.puts("❌ Application not found")
        
      application ->
        # Request summarization
        IO.puts("📋 Current summary status: #{application.summary_status}")
        
        case Applications.request_cv_summarization(application) do
          {:ok, job} ->
            IO.puts("✅ Summarization job scheduled: #{inspect(job.id)}")
            IO.puts("⏳ Check back in a moment for the results")
            
          {:error, error} ->
            IO.puts("❌ Failed to schedule summarization job: #{inspect(error)}")
        end
    end
    
    :ok
  end
  
  @doc """
  Check the status of a CV summarization.
  
  ## Parameters
    - application_id: The ID of the application to check
  """
  def check_cv_summary(application_id) do
    IO.puts("Checking CV summary for application ##{application_id}")
    
    case Applications.get_cv_summary(application_id) do
      {:ok, %{summary: nil, status: status}} ->
        IO.puts("⏳ Summary not yet available. Status: #{status}")
        
      {:ok, %{summary: summary, status: "completed"}} ->
        IO.puts("✅ Summary completed:")
        IO.puts("---")
        IO.puts(summary)
        IO.puts("---")
        
      {:ok, %{status: status}} ->
        IO.puts("⚠️ Summary in progress. Status: #{status}")
        
      {:error, reason} ->
        IO.puts("❌ Error: #{inspect(reason)}")
    end
    
    :ok
  end
end
