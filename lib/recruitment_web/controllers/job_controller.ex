defmodule RecruitmentWeb.JobController do
  use RecruitmentWeb, :controller

  alias Recruitment.Jobs
  alias Recruitment.Jobs.Job

  def index(conn, _params) do
    jobs = Jobs.list_jobs()
    render(conn, :index, jobs: jobs)
  end

  def show(conn, %{"location" => location, "slug" => slug}) do
    # Find the job by location and slug
    jobs = Jobs.list_jobs()
    
    job = Enum.find(jobs, fn job -> 
      job.location |> String.downcase() == String.downcase(location) && 
      job.slug == slug
    end)
    
    if job do
      render(conn, :show, job: job)
    else
      conn
      |> put_flash(:error, "Job not found")
      |> redirect(to: ~p"/jobs")
    end
  end
end
