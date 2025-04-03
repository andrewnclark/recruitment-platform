defmodule Recruitment.Workers.CVSummarizationWorkerTest do
  use Recruitment.DataCase
  use Oban.Testing, repo: Recruitment.Repo

  alias Recruitment.Applications
  alias Recruitment.Applications.Application
  alias Recruitment.Workers.CVSummarizationWorker
  alias Recruitment.Repo
  
  import Recruitment.JobsFixtures
  import Recruitment.ApplicationsFixtures

  setup do
    # Ensure our test application has a resume
    job = job_fixture()
    application = application_fixture(%{
      job_id: job.id,
      resume: "test_resume.pdf",
      summary_status: "pending"
    })
    
    %{application: application}
  end

  describe "CV summarization worker" do
    test "enqueues a job correctly", %{application: application} do
      assert {:ok, _job} = Applications.request_cv_summarization(application)
      
      assert_enqueued(worker: CVSummarizationWorker, args: %{application_id: application.id})
    end
    
    test "processes an application and updates its summary", %{application: application} do
      # Create a job for processing
      {:ok, job} = CVSummarizationWorker.new(%{application_id: application.id}) |> Oban.insert()
      
      # Process the job
      assert {:ok, :ok} = perform_job(CVSummarizationWorker, %{application_id: application.id})
      
      # Check that the application was updated
      updated_application = Repo.get!(Application, application.id)
      assert updated_application.summary_status == "completed"
      assert updated_application.cv_summary != nil
      assert is_binary(updated_application.cv_summary)
    end
    
    test "updates status to error when text extraction fails" do
      # Create an application without a resume
      job = job_fixture()
      application = application_fixture(%{job_id: job.id, resume: nil})
      
      # Process the job
      assert {:ok, {:error, _}} = perform_job(CVSummarizationWorker, %{application_id: application.id})
      
      # Check that the application was updated with error status
      updated_application = Repo.get!(Application, application.id)
      assert updated_application.summary_status == "error"
    end
    
    test "ensure_cv_summary skips if already processed", %{application: application} do
      # First, process the application
      assert {:ok, _} = Applications.request_cv_summarization(application)
      assert {:ok, :ok} = perform_job(CVSummarizationWorker, %{application_id: application.id})
      
      # Get the updated application
      updated_application = Repo.get!(Application, application.id)
      assert updated_application.summary_status == "completed"
      
      # Now try to ensure summary again - should be skipped
      assert {:ok, :already_processed} = Applications.ensure_cv_summary(updated_application.id)
      
      # Verify that no new job was enqueued
      assert all_enqueued() |> length() == 0
    end
    
    test "ensure_cv_summary schedules job if not processed", %{application: application} do
      # Reset the application to pending state
      Applications.update_application(application, %{summary_status: "pending"})
      
      # Ensure CV summary
      assert {:ok, :scheduled} = Applications.ensure_cv_summary(application.id)
      
      # Verify that a job was enqueued
      assert_enqueued(worker: CVSummarizationWorker, args: %{application_id: application.id})
    end
  end
  
  describe "CV summary lifecycle" do
    test "full lifecycle from request to retrieval", %{application: application} do
      # 1. Request summarization
      assert {:ok, _} = Applications.request_cv_summarization(application)
      
      # 2. Process the job
      assert {:ok, :ok} = perform_job(CVSummarizationWorker, %{application_id: application.id})
      
      # 3. Retrieve the summary
      assert {:ok, %{summary: summary, status: "completed"}} = Applications.get_cv_summary(application.id)
      assert is_binary(summary)
      assert String.length(summary) > 0
    end
  end
end
