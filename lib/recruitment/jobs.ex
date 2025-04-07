defmodule Recruitment.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Recruitment.Repo
  alias Recruitment.Jobs.Job

  # Custom error types
  defmodule Error do
    defexception [:message, :code, :details]

    @type t :: %__MODULE__{
      message: String.t(),
      code: atom(),
      details: map() | nil
    }

    def exception(opts) do
      message = Keyword.get(opts, :message, "An error occurred")
      code = Keyword.get(opts, :code, :unknown_error)
      details = Keyword.get(opts, :details, nil)

      %__MODULE__{message: message, code: code, details: details}
    end
  end

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  @doc """
  Gets a single job.

  Returns {:ok, job} if found, {:error, reason} otherwise.

  ## Examples

      iex> get_job(123)
      {:ok, %Job{}}

      iex> get_job(456)
      {:error, %Error{message: "Job not found", code: :not_found}}

  """
  def get_job(id) do
    case Repo.get(Job, id) do
      nil -> 
        {:error, %Error{message: "Job not found", code: :not_found}}
      job -> 
        {:ok, job}
    end
  end

  @doc """
  Gets a single job and raises if not found.

  Raises `Error` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Recruitment.Jobs.Error)

  """
  def get_job!(id) do
    case get_job(id) do
      {:ok, job} -> job
      {:error, error} -> raise error
    end
  end

  @doc """
  Gets a job by its location and slug.

  Returns {:ok, job} if found, {:error, reason} otherwise.

  ## Examples

      iex> get_job_by_location_and_slug("new-york", "software-engineer")
      {:ok, %Job{}}

      iex> get_job_by_location_and_slug("invalid", "invalid")
      {:error, %Error{message: "Job not found", code: :not_found}}

  """
  def get_job_by_location_and_slug(location, slug) when is_binary(location) and is_binary(slug) do
    location = String.downcase(location)
    
    case Job
         |> where([j], fragment("lower(?)", j.location) == ^location and j.slug == ^slug)
         |> Repo.one() do
      nil -> 
        {:error, %Error{
          message: "Job not found for location '#{location}' and slug '#{slug}'",
          code: :not_found
        }}
      job -> 
        {:ok, job}
    end
  end

  @doc """
  Gets a list of published jobs.

  Returns {:ok, jobs} if successful, {:error, reason} otherwise.

  ## Examples

      iex> list_published_jobs()
      {:ok, [%Job{}, ...]}

  """
  def list_published_jobs do
    today = Date.utc_today()
    
    jobs = Job
           |> where([j], j.published == true)
           |> where([j], is_nil(j.expiry_date) or j.expiry_date >= ^today)
           |> order_by([j], desc: j.inserted_at)
           |> Repo.all()
    
    {:ok, jobs}
  end

  @doc """
  Gets a list of published jobs by category.

  ## Examples

      iex> list_published_jobs_by_category("engineering")
      [%Job{}, ...]

  """
  def list_published_jobs_by_category(category) when is_binary(category) do
    today = Date.utc_today()
    
    Job
    |> where([j], j.published == true)
    |> where([j], is_nil(j.expiry_date) or j.expiry_date >= ^today)
    |> where([j], j.category == ^category)
    |> order_by([j], desc: j.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a list of published jobs by location.

  ## Examples

      iex> list_published_jobs_by_location("new-york")
      [%Job{}, ...]

  """
  def list_published_jobs_by_location(location) when is_binary(location) do
    today = Date.utc_today()
    location = String.downcase(location)
    
    Job
    |> where([j], j.published == true)
    |> where([j], is_nil(j.expiry_date) or j.expiry_date >= ^today)
    |> where([j], fragment("lower(?)", j.location) == ^location)
    |> order_by([j], desc: j.inserted_at)
    |> Repo.all()
  end

  @doc """
  Creates a job.

  Returns {:ok, job} if successful, {:error, reason} otherwise.

  ## Examples

      iex> create_job(%{title: "Developer"})
      {:ok, %Job{}}

      iex> create_job(%{title: nil})
      {:error, %Error{message: "Invalid job data", code: :validation_error, details: %{title: ["can't be blank"]}}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
    |> handle_result()
  end

  @doc """
  Updates a job.

  Returns {:ok, job} if successful, {:error, reason} otherwise.

  ## Examples

      iex> update_job(job, %{title: "New Title"})
      {:ok, %Job{}}

      iex> update_job(job, %{title: nil})
      {:error, %Error{message: "Invalid job data", code: :validation_error, details: %{title: ["can't be blank"]}}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
    |> handle_result()
  end

  @doc """
  Updates a job and regenerates its slug based on the current title.
  Use this when you specifically want to update the slug.

  ## Examples

      iex> regenerate_job_slug(job, %{field: new_value})
      {:ok, %Job{}}

      iex> regenerate_job_slug(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def regenerate_job_slug(%Job{} = job, attrs \\ %{}) do
    job
    |> Job.regenerate_slug_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  Returns {:ok, job} if successful, {:error, reason} otherwise.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Error{message: "Could not delete job", code: :delete_error}}

  """
  def delete_job(%Job{} = job) do
    case Repo.delete(job) do
      {:ok, job} -> {:ok, job}
      {:error, changeset} -> 
        {:error, %Error{
          message: "Could not delete job",
          code: :delete_error,
          details: format_changeset_errors(changeset)
        }}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end

  # Helper function to handle database results
  defp handle_result({:ok, job}), do: {:ok, job}
  defp handle_result({:error, changeset}) do
    {:error, %Error{
      message: "Invalid job data",
      code: :validation_error,
      details: format_changeset_errors(changeset)
    }}
  end

  # Helper function to format changeset errors into a more readable format
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
