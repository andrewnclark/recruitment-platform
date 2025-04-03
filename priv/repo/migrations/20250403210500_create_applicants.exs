defmodule Recruitment.Repo.Migrations.CreateApplicants do
  use Ecto.Migration

  def change do
    create table(:applicants) do
      add :email, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :phone, :string
      add :notes, :text

      timestamps()
    end

    create unique_index(:applicants, [:email])
    
    # Add applicant_id to applications table
    alter table(:applications) do
      add :applicant_id, references(:applicants, on_delete: :nilify_all)
    end
    
    create index(:applications, [:applicant_id])
  end
end
