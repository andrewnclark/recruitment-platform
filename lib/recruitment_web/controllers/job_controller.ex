defmodule RecruitmentWeb.JobController do
  use RecruitmentWeb, :controller

  alias Recruitment.Jobs
  alias Recruitment.Jobs.Job

  def index(conn, _params) do
    jobs = Jobs.list_published_jobs()
    render(conn, :index, jobs: jobs)
  end

  def show(conn, %{"location" => location, "slug" => slug}) do
    case Jobs.get_job_by_location_and_slug(location, slug) do
      nil ->
        conn
        |> put_flash(:error, "Job not found")
        |> redirect(to: ~p"/jobs")
      job ->
        render(conn, :show, job: job)
    end
  end
end
