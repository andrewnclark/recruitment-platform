defmodule RecruitmentWeb.Admin.SessionController do
  use RecruitmentWeb, :controller
  
  alias RecruitmentWeb.AdminAuthPlug

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    conn
    |> AdminAuthPlug.login(username, password)
    |> case do
      %{assigns: %{admin_authenticated: true}} = conn ->
        conn |> redirect(to: ~p"/")
      conn ->
        conn |> render(:new)
    end
  end

  def delete(conn, _params) do
    conn
    |> AdminAuthPlug.logout()
    |> redirect(to: ~p"/login")
  end
end
