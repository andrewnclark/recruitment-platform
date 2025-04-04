defmodule RecruitmentWeb.AdminAuthPlug do
  @moduledoc """
  A plug for authenticating admin users.
  
  This is a basic implementation for demonstration purposes.
  In a production environment, you would want to implement a more robust
  authentication system with proper user management and password hashing.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias RecruitmentWeb.Router.Helpers, as: Routes

  # Hard-coded credentials for demonstration
  # In a real app, these would come from a database
  @admin_username "admin"
  @admin_password "adminpassword123"

  def init(opts), do: opts

  def call(conn, _opts) do
    case authenticate_admin(conn) do
      {:ok, conn} ->
        conn |> assign(:admin_authenticated, true)
      {:error, conn} ->
        conn
        |> put_flash(:error, "Admin authentication required")
        |> redirect(to: "/login")
        |> halt()
    end
  end

  # Check if user is authenticated via session
  defp authenticate_admin(conn) do
    if get_session(conn, :admin_authenticated) do
      {:ok, conn}
    else
      {:error, conn}
    end
  end

  @doc """
  Authenticates an admin user with username and password.
  """
  def authenticate_admin(username, password) do
    # Simple credentials check - in a real app, use proper password hashing
    if username == @admin_username && password == @admin_password do
      :ok
    else
      :error
    end
  end

  @doc """
  A helper function to handle login.
  """
  def login(conn, username, password) do
    case authenticate_admin(username, password) do
      :ok ->
        conn
        |> put_session(:admin_authenticated, true)
        |> assign(:admin_authenticated, true)
        |> put_flash(:info, "Welcome to the admin panel!")
      :error ->
        conn
        |> put_flash(:error, "Invalid credentials")
    end
  end

  @doc """
  A helper function to handle logout.
  """
  def logout(conn) do
    conn
    |> delete_session(:admin_authenticated)
    |> put_flash(:info, "Logged out successfully")
  end
end
