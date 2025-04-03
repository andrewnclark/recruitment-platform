defmodule Recruitment.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :title, :string, null: false
      add :summary, :text, null: false
      add :description, :text, null: false
      add :responsibilities, :text
      add :requirements, :text
      add :benefits, :text
      add :location, :string, null: false
      add :job_type, :string, null: false
      add :category, :string, null: false
      add :min_salary, :integer
      add :max_salary, :integer
      add :published, :boolean, default: false
      add :expiry_date, :date
      add :slug, :string, null: false

      timestamps()
    end

    create index(:jobs, [:title])
    create index(:jobs, [:slug])
    create index(:jobs, [:location])
    create index(:jobs, [:job_type])
    create index(:jobs, [:category])
    create index(:jobs, [:published])
  end
end
