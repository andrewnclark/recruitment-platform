defmodule Recruitment.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :title, :string
    field :description, :string
    field :requirements, :string
    field :location, :string
    field :salary, :string

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:title, :description, :requirements, :location, :salary])
    |> validate_required([:title, :description])
  end
end
