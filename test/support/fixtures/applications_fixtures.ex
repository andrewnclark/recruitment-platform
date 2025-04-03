defmodule Recruitment.ApplicationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Recruitment.Applications` context.
  """

  alias Recruitment.JobsFixtures
  alias Recruitment.Jobs

  @doc """
  Generate an application.
  """
  def application_fixture(attrs \\ %{}) do
    # Create a job if job_id is not provided
    {job_id, attrs} = if Map.has_key?(attrs, :job_id) || Map.has_key?(attrs, "job_id") do
      {Map.get(attrs, :job_id) || Map.get(attrs, "job_id"), attrs}
    else
      job = JobsFixtures.job_fixture()
      {job.id, attrs}
    end

    {:ok, application} =
      attrs
      |> Enum.into(%{
        first_name: "John",
        last_name: "Doe",
        email: "john.doe@example.com",
        phone: "555-123-4567",
        cover_letter: "I am very interested in this position.",
        resume: "resume.pdf",
        job_id: job_id
      })
      |> Recruitment.Applications.create_application()

    application
  end

  @doc """
  Generate a job and an application for that job.
  Returns {job, application} tuple.
  """
  def job_with_application_fixture(job_attrs \\ %{}, application_attrs \\ %{}) do
    job = JobsFixtures.job_fixture(job_attrs)
    
    application = application_fixture(
      Map.merge(application_attrs, %{job_id: job.id})
    )
    
    {job, application}
  end
end
