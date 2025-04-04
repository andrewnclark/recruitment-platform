defmodule RecruitmentWeb.Admin.ApplicantController do
  use RecruitmentWeb, {:admin_controller, []}

  alias Recruitment.Applicants
  alias Recruitment.Applicants.Applicant

  def index(conn, _params) do
    applicants = Applicants.list_applicants()
    render(conn, :index, applicants: applicants)
  end

  def show(conn, %{"id" => id}) do
    applicant = Applicants.get_applicant!(id)
    applications = Applicants.get_applicant_applications(applicant)
    latest_resume = Applicants.get_latest_resume(applicant)
    
    render(conn, :show, 
      applicant: applicant, 
      applications: applications,
      latest_resume: latest_resume
    )
  end

  def edit(conn, %{"id" => id}) do
    applicant = Applicants.get_applicant!(id)
    changeset = Applicants.change_applicant(applicant)
    render(conn, :edit, applicant: applicant, changeset: changeset)
  end

  def update(conn, %{"id" => id, "applicant" => applicant_params}) do
    applicant = Applicants.get_applicant!(id)

    case Applicants.update_applicant(applicant, applicant_params) do
      {:ok, applicant} ->
        conn
        |> put_flash(:info, "Applicant updated successfully.")
        |> redirect(to: ~p"/applicants/#{applicant}")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, applicant: applicant, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    applicant = Applicants.get_applicant!(id)
    {:ok, _applicant} = Applicants.delete_applicant(applicant)

    conn
    |> put_flash(:info, "Applicant deleted successfully.")
    |> redirect(to: ~p"/applicants")
  end
end
