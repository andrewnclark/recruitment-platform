defmodule Recruitment.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :requirements, :text
      add :location, :string, null: false
      add :salary, :string
      add :slug, :string

      timestamps()
    end

    create index(:jobs, [:title])
    create index(:jobs, [:slug])
    create index(:jobs, [:location])
  end
end
