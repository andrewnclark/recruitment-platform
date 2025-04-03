defmodule Recruitment.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :requirements, :text
      add :location, :string
      add :salary, :string

      timestamps()
    end

    create index(:jobs, [:title])
  end
end
