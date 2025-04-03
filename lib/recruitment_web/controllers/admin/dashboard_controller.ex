defmodule RecruitmentWeb.Admin.DashboardController do
  use RecruitmentWeb, :controller

  alias Recruitment.Jobs
  alias Recruitment.Applications

  def index(conn, _params) do
    # Get counts for the dashboard
    job_count = length(Jobs.list_jobs())
    application_count = length(Applications.list_applications())
    
    # Get recent applications (top 5)
    recent_applications = 
      Applications.list_applications()
      |> Enum.sort_by(fn app -> app.inserted_at end, {:desc, DateTime})
      |> Enum.take(5)
    
    # Get application statistics by status
    applications = Applications.list_applications()
    status_counts = Enum.reduce(applications, %{}, fn app, acc ->
      Map.update(acc, app.status, 1, &(&1 + 1))
    end)
    
    render(conn, :index, 
      job_count: job_count,
      application_count: application_count,
      recent_applications: recent_applications,
      status_counts: status_counts
    )
  end
end
