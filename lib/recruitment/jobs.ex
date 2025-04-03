defmodule Recruitment.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Recruitment.Repo

  alias Recruitment.Jobs.Job

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

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Gets a job by its location and slug.

  Returns nil if no job is found.

  ## Examples

      iex> get_job_by_location_and_slug("new-york", "software-engineer")
      %Job{}

      iex> get_job_by_location_and_slug("invalid", "invalid")
      nil

  """
  def get_job_by_location_and_slug(location, slug) when is_binary(location) and is_binary(slug) do
    location = String.downcase(location)
    Job
    |> where([j], fragment("lower(?)", j.location) == ^location and j.slug == ^slug)
    |> Repo.one()
  end

  @doc """
  Gets a list of published jobs.

  ## Examples

      iex> list_published_jobs()
      [%Job{}, ...]

  """
  def list_published_jobs do
    today = Date.utc_today()
    
    Job
    |> where([j], j.published == true)
    |> where([j], is_nil(j.expiry_date) or j.expiry_date >= ^today)
    |> order_by([j], desc: j.inserted_at)
    |> Repo.all()
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

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
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

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
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
end
