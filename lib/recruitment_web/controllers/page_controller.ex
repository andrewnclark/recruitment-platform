defmodule RecruitmentWeb.PageController do
  use RecruitmentWeb, :controller
  alias Recruitment.Jobs

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    # Get featured jobs (published jobs, limited to 3)
    featured_jobs = Jobs.list_published_jobs() |> Enum.take(3)
    render(conn, :home, featured_jobs: featured_jobs)
  end
  
  def not_found(conn, _params) do
    conn
    |> put_status(404)
    |> put_view(html: RecruitmentWeb.ErrorHTML)
    |> render(:"404")
  end
end
