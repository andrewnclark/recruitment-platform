defmodule Recruitment.Repo do
  use Ecto.Repo,
    otp_app: :recruitment,
    adapter: Ecto.Adapters.Postgres
end
