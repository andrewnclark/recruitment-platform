defmodule Recruitment.Applications do
  @moduledoc """
  The Applications context.
  """

  import Ecto.Query, warn: false
  alias Recruitment.Repo

  alias Recruitment.Applications.Application
  alias Recruitment.Jobs
  alias Recruitment.Applicants
  alias Recruitment.Workers.CVSummarizationWorker

  @doc """
  Returns the list of applications.

  ## Examples

      iex> list_applications()
      [%Application{}, ...]

  """
  def list_applications do
    Repo.all(Application)
    |> Repo.preload([:job, :applicant])
  end

  @doc """
  Gets a single application.

  Raises `Ecto.NoResultsError` if the Application does not exist.

  ## Examples

      iex> get_application!(123)
      %Application{}

      iex> get_application!(456)
      ** (Ecto.NoResultsError)

  """
  def get_application!(id) do
    Repo.get!(Application, id)
    |> Repo.preload([:job, :applicant])
  end

  @doc """
  Creates a application.

  ## Examples

      iex> create_application(%{field: value})
      {:ok, %Application{}}

      iex> create_application(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_application(attrs \\ %{}) do
    # First, get or create an applicant based on the email
    applicant_attrs = %{
      email: attrs[:email] || attrs["email"],
      first_name: attrs[:first_name] || attrs["first_name"],
      last_name: attrs[:last_name] || attrs["last_name"],
      phone: attrs[:phone] || attrs["phone"]
    }

    with {:ok, applicant} <- Applicants.get_or_create_applicant_by_email(applicant_attrs) do
      # Then create the application with the applicant_id
      attrs_with_applicant = Map.put(attrs, :applicant_id, applicant.id)

      %Application{}
      |> Application.changeset(attrs_with_applicant)
      |> Repo.insert()
    end
  end

  @doc """
  Updates a application.

  ## Examples

      iex> update_application(application, %{field: new_value})
      {:ok, %Application{}}

      iex> update_application(application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_application(%Application{} = application, attrs) do
    application
    |> Application.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a application.

  ## Examples

      iex> delete_application(application)
      {:ok, %Application{}}

      iex> delete_application(application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_application(%Application{} = application) do
    Repo.delete(application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking application changes.

  ## Examples

      iex> change_application(application)
      %Ecto.Changeset{data: %Application{}}

  """
  def change_application(%Application{} = application, attrs \\ %{}) do
    Application.changeset(application, attrs)
  end
  
  @doc """
  Gets a job by location and slug.
  Delegates to Jobs context to maintain proper context separation.
  Returns nil if no job is found.
  
  ## Examples
  
      iex> get_job_by_location_and_slug("london", "software-engineer")
      %Jobs.Job{}
      
      iex> get_job_by_location_and_slug("invalid", "invalid")
      nil
  """
  def get_job_by_location_and_slug(location, slug) do
    Jobs.get_job_by_location_and_slug(location, slug)
  end
  
  @doc """
  Requests a CV summarization for an application.
  
  This function schedules a background job using Oban to generate
  a summary of the applicant's resume.
  
  ## Parameters
    - application: The application to summarize
    
  ## Returns
    - {:ok, %Oban.Job{}} - Job was successfully scheduled
    - {:error, %Ecto.Changeset{}} - Failed to schedule job
  """
  def request_cv_summarization(%Application{} = application) do
    %{application_id: application.id}
    |> CVSummarizationWorker.new()
    |> Oban.insert()
  end
  
  @doc """
  Gets the CV summary for an application.
  
  ## Parameters
    - application_id: The ID of the application
    
  ## Returns
    - {:ok, %{summary: summary, status: status}} - The summary and status
    - {:error, :not_found} - Application not found
  """
  def get_cv_summary(application_id) do
    case Repo.get(Application, application_id) do
      nil -> 
        {:error, :not_found}
      application -> 
        {:ok, %{
          summary: application.cv_summary,
          status: application.summary_status
        }}
    end
  end
  
  @doc """
  Triggers CV summarization for an application if it hasn't been processed yet.
  
  This function checks the current summary status and schedules a new
  summarization job if needed.
  
  ## Parameters
    - application_id: The ID of the application
    
  ## Returns
    - {:ok, :scheduled} - Job was successfully scheduled
    - {:ok, :already_processed} - Summary already exists
    - {:error, reason} - Failed to schedule job
  """
  def ensure_cv_summary(application_id) do
    case Repo.get(Application, application_id) do
      nil -> 
        {:error, :not_found}
      application -> 
        case application.summary_status do
          status when status in ["completed", "processing"] ->
            {:ok, :already_processed}
          _ ->
            case request_cv_summarization(application) do
              {:ok, _job} -> {:ok, :scheduled}
              error -> error
            end
        end
    end
  end
end
