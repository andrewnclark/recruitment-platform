defmodule Recruitment.Applicants do
  @moduledoc """
  The Applicants context.
  """

  import Ecto.Query, warn: false
  alias Recruitment.Repo

  alias Recruitment.Applicants.Applicant
  alias Recruitment.Applications.Application

  @doc """
  Returns the list of applicants.

  ## Examples

      iex> list_applicants()
      [%Applicant{}, ...]

  """
  def list_applicants do
    Repo.all(from a in Applicant, preload: [:applications])
  end

  @doc """
  Gets a single applicant.

  Raises `Ecto.NoResultsError` if the Applicant does not exist.

  ## Examples

      iex> get_applicant!(123)
      %Applicant{}

      iex> get_applicant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_applicant!(id), do: Repo.get!(Applicant, id)

  @doc """
  Gets a single applicant by email.

  Returns nil if the Applicant does not exist.

  ## Examples

      iex> get_applicant_by_email("user@example.com")
      %Applicant{}

      iex> get_applicant_by_email("nonexistent@example.com")
      nil

  """
  def get_applicant_by_email(email) when is_binary(email) do
    Repo.get_by(Applicant, email: email)
  end

  @doc """
  Creates a applicant.

  ## Examples

      iex> create_applicant(%{field: value})
      {:ok, %Applicant{}}

      iex> create_applicant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_applicant(attrs \\ %{}) do
    %Applicant{}
    |> Applicant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a applicant.

  ## Examples

      iex> update_applicant(applicant, %{field: new_value})
      {:ok, %Applicant{}}

      iex> update_applicant(applicant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_applicant(%Applicant{} = applicant, attrs) do
    applicant
    |> Applicant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a applicant.

  ## Examples

      iex> delete_applicant(applicant)
      {:ok, %Applicant{}}

      iex> delete_applicant(applicant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_applicant(%Applicant{} = applicant) do
    Repo.delete(applicant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking applicant changes.

  ## Examples

      iex> change_applicant(applicant)
      %Ecto.Changeset{data: %Applicant{}}

  """
  def change_applicant(%Applicant{} = applicant, attrs \\ %{}) do
    Applicant.changeset(applicant, attrs)
  end

  @doc """
  Gets or creates an applicant by email.
  If an applicant with the given email exists, returns that applicant.
  Otherwise, creates a new applicant with the provided attributes.

  ## Examples

      iex> get_or_create_applicant_by_email(%{email: "user@example.com", first_name: "John", last_name: "Doe"})
      {:ok, %Applicant{}}

  """
  def get_or_create_applicant_by_email(attrs) when is_map(attrs) do
    email = attrs[:email] || attrs["email"]
    
    if applicant = get_applicant_by_email(email) do
      {:ok, applicant}
    else
      create_applicant(attrs)
    end
  end

  @doc """
  Returns all applications for a given applicant.

  ## Examples

      iex> get_applicant_applications(applicant)
      [%Application{}, ...]

  """
  def get_applicant_applications(%Applicant{} = applicant) do
    Repo.all(
      from a in Application,
      where: a.applicant_id == ^applicant.id,
      order_by: [desc: a.inserted_at],
      preload: [:job]
    )
  end

  @doc """
  Returns the latest resume for an applicant, if any.

  ## Examples

      iex> get_latest_resume(applicant)
      "https://example.com/resume.pdf"

      iex> get_latest_resume(applicant_with_no_resume)
      nil

  """
  def get_latest_resume(%Applicant{} = applicant) do
    latest_application_with_resume =
      Repo.one(
        from a in Application,
        where: a.applicant_id == ^applicant.id and not is_nil(a.resume),
        order_by: [desc: a.inserted_at],
        limit: 1,
        select: a
      )

    if latest_application_with_resume, do: latest_application_with_resume.resume, else: nil
  end
end
