defmodule Recruitment.Repo.Migrations.CreateApplications do
  use Ecto.Migration

  def change do
    create table(:applications) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :cover_letter, :text
      add :resume, :string
      add :status, :string, default: "submitted"
      add :job_id, references(:jobs, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:applications, [:job_id])
    create index(:applications, [:email])
    create index(:applications, [:status])
  end
end
