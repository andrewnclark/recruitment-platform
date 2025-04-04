defmodule RecruitmentWeb.Apply.ApplicationController do
  use RecruitmentWeb, {:apply_controller, []}

  alias Recruitment.Applications
  alias Recruitment.Applications.Application
  alias Recruitment.Jobs

  def index(conn, _params) do
    # List all available jobs for the application portal home page
    jobs = Jobs.list_jobs()
    render(conn, :index, jobs: jobs)
  end

  def new(conn, %{"location" => location, "slug" => slug}) do
    # Find the job by location and slug
    case Applications.get_job_by_location_and_slug(location, slug) do
      nil ->
        conn
        |> put_flash(:error, "Job not found")
        |> redirect(to: ~p"/")
      
      job ->
        changeset = Applications.change_application(%Application{job_id: job.id})
        # Generate the action URL string for the form
        action = ~p"/#{location}/#{slug}"
        render(conn, :new, changeset: changeset, job: job, action: action)
    end
  end

  def create(conn, %{"location" => location, "slug" => slug, "application" => application_params}) do
    # Find the job by location and slug
    case Applications.get_job_by_location_and_slug(location, slug) do
      nil ->
        conn
        |> put_flash(:error, "Job not found")
        |> redirect(to: ~p"/")
      
      job ->
        # Add the job_id to the application params
        application_params = Map.put(application_params, "job_id", job.id)
        
        case Applications.create_application(application_params) do
          {:ok, _application} ->
            conn
            |> put_flash(:info, "Application submitted successfully!")
            |> redirect(to: ~p"/#{location}/#{slug}/success")
          
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :new, changeset: changeset, job: job)
        end
    end
  end

  def success(conn, %{"location" => location, "slug" => slug}) do
    # Find the job by location and slug
    case Applications.get_job_by_location_and_slug(location, slug) do
      nil ->
        conn
        |> put_flash(:error, "Job not found")
        |> redirect(to: ~p"/")
      
      job ->
        render(conn, :success, job: job)
    end
  end
end
