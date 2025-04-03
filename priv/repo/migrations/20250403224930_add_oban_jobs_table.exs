defmodule Recruitment.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def change do
    Oban.Migration.up()

    # Create an index to optimize job lookups
    create index(:oban_jobs, [:queue, :state])
  end

  # We specify a down function to handle rollbacks
  def down do
    Oban.Migration.down(version: 1)
  end
end
