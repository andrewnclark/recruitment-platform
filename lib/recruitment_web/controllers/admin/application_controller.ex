defmodule RecruitmentWeb.Admin.ApplicationController do
  use RecruitmentWeb, :controller
  import Phoenix.LiveView.Controller

  alias Recruitment.Applications
  alias Recruitment.Jobs
  alias Phoenix.PubSub

  def index(conn, _params) do
    applications = Applications.list_applications()
    render(conn, :index, applications: applications)
  end

  def show(conn, %{"id" => id}) do
    application = Applications.get_application!(id)
    job = Jobs.get_job!(application.job_id)
    
    # Subscribe to PubSub updates for this application
    if connected?(conn) do
      PubSub.subscribe(Recruitment.PubSub, "application:#{application.id}:summary")
    end
    
    render(conn, :show, application: application, job: job)
  end

  def update(conn, %{"id" => id, "application" => application_params}) do
    application = Applications.get_application!(id)

    case Applications.update_application(application, application_params) do
      {:ok, application} ->
        conn
        |> put_flash(:info, "Application updated successfully.")
        |> redirect(to: ~p"/applications/#{application.id}")
      {:error, %Ecto.Changeset{} = changeset} ->
        job = Jobs.get_job!(application.job_id)
        render(conn, :edit, application: application, changeset: changeset, job: job)
    end
  end

  def delete(conn, %{"id" => id}) do
    application = Applications.get_application!(id)
    {:ok, _application} = Applications.delete_application(application)

    conn
    |> put_flash(:info, "Application deleted successfully.")
    |> redirect(to: ~p"/applications")
  end
end
