defmodule Recruitment.Applicants.Applicant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "applicants" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :notes, :string

    has_many :applications, Recruitment.Applications.Application, foreign_key: :applicant_id

    timestamps()
  end

  @doc false
  def changeset(applicant, attrs) do
    applicant
    |> cast(attrs, [:email, :first_name, :last_name, :phone, :notes])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end
end
