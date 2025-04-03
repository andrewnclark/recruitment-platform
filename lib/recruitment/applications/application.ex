defmodule Recruitment.Applications.Application do
  use Ecto.Schema
  import Ecto.Changeset

  schema "applications" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone, :string
    field :cover_letter, :string
    field :resume, :string
    field :status, :string, default: "submitted"
    
    # Reference to the job
    field :job_id, :id

    timestamps()
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [:first_name, :last_name, :email, :phone, :cover_letter, :resume, :job_id])
    |> validate_required([:first_name, :last_name, :email, :job_id])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end
end
