defmodule Recruitment.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias Recruitment.Jobs.Job

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
end
