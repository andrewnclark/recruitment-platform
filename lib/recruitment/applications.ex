defmodule Recruitment.Applications do
  @moduledoc """
  The Applications context.
  """

  import Ecto.Query, warn: false
  alias Recruitment.Repo

  alias Recruitment.Applications.Application
  alias Recruitment.Jobs
  alias Recruitment.Applicants

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
end
