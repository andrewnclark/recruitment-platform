defmodule Recruitment.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset
  import Slugify
  alias Recruitment.Jobs.Job
  alias Recruitment.Repo

  schema "jobs" do
    field :title, :string
    field :summary, :string
    field :description, :string
    field :responsibilities, :string
    field :requirements, :string
    field :benefits, :string
    field :location, :string
    field :job_type, :string
    field :category, :string
    field :min_salary, :integer
    field :max_salary, :integer
    field :published, :boolean, default: false
    field :expiry_date, :date
    field :slug, :string

    has_many :applications, Recruitment.Applications.Application

    timestamps()
  end

  @required_fields [:title, :summary, :description, :location, :job_type, :category]
  @job_types ["full_time", "part_time", "contract", "internship", "temporary"]
  @categories ["engineering", "design", "product", "marketing", "sales", "operations", "data", "other"]

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:title, :summary, :description, :responsibilities, :requirements, :benefits, 
                    :location, :job_type, :category, :min_salary, :max_salary, :published, 
                    :expiry_date, :slug])
    |> validate_required(@required_fields, message: "is required")
    |> validate_length(:title, min: 3, max: 100, message: "must be between 3 and 100 characters")
    |> validate_length(:summary, min: 10, max: 200, message: "must be between 10 and 200 characters")
    |> validate_length(:description, min: 50, message: "must be at least 50 characters")
    |> validate_inclusion(:job_type, @job_types, message: "must be one of: #{Enum.join(@job_types, ", ")}")
    |> validate_inclusion(:category, @categories, message: "must be one of: #{Enum.join(@categories, ", ")}")
    |> validate_number(:min_salary, 
      greater_than_or_equal_to: 0, 
      allow_nil: true,
      message: "must be a positive number"
    )
    |> validate_number(:max_salary, 
      greater_than_or_equal_to: 0, 
      allow_nil: true,
      message: "must be a positive number"
    )
    |> validate_min_max_salary()
    |> validate_expiry_date()
    |> maybe_generate_slug()
    |> unique_constraint(:slug, message: "a job with this title already exists")
  end

  @doc """
  Creates a changeset that will update the slug based on the current title.
  Use this function when you specifically want to regenerate the slug.
  """
  def regenerate_slug_changeset(job, attrs \\ %{}) do
    job
    |> cast(attrs, [:title, :summary, :description, :responsibilities, :requirements, :benefits, 
                    :location, :job_type, :category, :min_salary, :max_salary, :published, 
                    :expiry_date])
    |> validate_required(@required_fields, message: "is required")
    |> validate_length(:title, min: 3, max: 100, message: "must be between 3 and 100 characters")
    |> validate_length(:summary, min: 10, max: 200, message: "must be between 10 and 200 characters")
    |> validate_length(:description, min: 50, message: "must be at least 50 characters")
    |> validate_inclusion(:job_type, @job_types, message: "must be one of: #{Enum.join(@job_types, ", ")}")
    |> validate_inclusion(:category, @categories, message: "must be one of: #{Enum.join(@categories, ", ")}")
    |> validate_number(:min_salary, 
      greater_than_or_equal_to: 0, 
      allow_nil: true,
      message: "must be a positive number"
    )
    |> validate_number(:max_salary, 
      greater_than_or_equal_to: 0, 
      allow_nil: true,
      message: "must be a positive number"
    )
    |> validate_min_max_salary()
    |> validate_expiry_date()
    |> force_generate_slug()
    |> unique_constraint(:slug, message: "a job with this title already exists")
  end
  
  defp validate_min_max_salary(changeset) do
    min_salary = get_field(changeset, :min_salary)
    max_salary = get_field(changeset, :max_salary)

    cond do
      min_salary != nil && max_salary != nil && min_salary > max_salary ->
        add_error(changeset, :max_salary, "must be greater than minimum salary")
      min_salary != nil && max_salary != nil && max_salary < min_salary ->
        add_error(changeset, :min_salary, "must be less than maximum salary")
      true ->
        changeset
    end
  end

  defp validate_expiry_date(changeset) do
    expiry_date = get_field(changeset, :expiry_date)
    today = Date.utc_today()

    if expiry_date != nil && Date.compare(expiry_date, today) == :lt do
      add_error(changeset, :expiry_date, "must be in the future")
    else
      changeset
    end
  end
  
  # Only generate a slug for new records (no ID) or if slug is explicitly set to nil
  defp maybe_generate_slug(changeset) do
    case {get_field(changeset, :id), get_field(changeset, :slug)} do
      {nil, nil} ->
        # New record with no slug - generate one from title
        generate_slug_from_title(changeset)
      {_, nil} ->
        # Existing record with slug explicitly set to nil - regenerate
        generate_slug_from_title(changeset)
      _ ->
        # Existing record with a slug or new record with slug provided - keep it
        changeset
    end
  end

  # Always generate a new slug regardless of whether one exists
  defp force_generate_slug(changeset) do
    generate_slug_from_title(changeset)
  end
  
  defp generate_slug_from_title(changeset) do
    case get_field(changeset, :title) do
      nil -> changeset
      title -> put_change(changeset, :slug, slugify(title))
    end
  end
  
  @doc """
  Renders markdown content as HTML.
  
  ## Examples
  
      iex> Job.markdown_to_html("**Bold text**")
      "<p><strong>Bold text</strong></p>\\n"
  
  """
  def markdown_to_html(nil), do: ""
  def markdown_to_html(markdown) do
    Earmark.as_html!(markdown)
  end
end
