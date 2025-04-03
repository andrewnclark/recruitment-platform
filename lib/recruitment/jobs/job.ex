defmodule Recruitment.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias Recruitment.Jobs.Job
  alias Recruitment.Repo

  schema "jobs" do
    field :title, :string
    field :description, :string
    field :requirements, :string
    field :location, :string
    field :salary, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:title, :description, :requirements, :location, :salary])
    |> validate_required([:title, :description, :location])
    |> generate_slug()
    |> ensure_unique_slug()
  end
  
  defp generate_slug(%Ecto.Changeset{valid?: true, changes: %{title: title}} = changeset) do
    slug = title
           |> String.downcase()
           |> String.replace(~r/[^a-z0-9\s-]/, "")
           |> String.replace(~r/\s+/, "-")
           |> String.trim("-")
    
    put_change(changeset, :slug, slug)
  end
  
  defp generate_slug(changeset), do: changeset
  
  defp ensure_unique_slug(%Ecto.Changeset{valid?: true, changes: %{slug: slug}} = changeset) do
    case find_slug_conflicts(slug, get_field(changeset, :id)) do
      0 -> 
        # No conflicts, slug is unique
        changeset
      _ -> 
        # Conflicts found, append a unique identifier
        put_change(changeset, :slug, "#{slug}-#{unique_suffix()}")
    end
  end
  
  defp ensure_unique_slug(changeset), do: changeset
  
  defp find_slug_conflicts(slug, nil) do
    # For new records (no ID)
    Repo.aggregate(from(j in Job, where: j.slug == ^slug), :count)
  end
  
  defp find_slug_conflicts(slug, id) do
    # For existing records (exclude the current record)
    Repo.aggregate(from(j in Job, where: j.slug == ^slug and j.id != ^id), :count)
  end
  
  defp unique_suffix do
    # Generate a random 6-character alphanumeric suffix
    :crypto.strong_rand_bytes(3)
    |> Base.encode16(case: :lower)
  end
end
