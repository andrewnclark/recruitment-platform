defmodule Recruitment.Repo.Migrations.AddCvSummaryToApplication do
  use Ecto.Migration

  def change do
    alter table(:applications) do
      add :cv_summary, :text
      add :summary_status, :string, default: "pending"
    end

    # Create an index for filtering applications by summary status
    create index(:applications, [:summary_status])
  end
end
