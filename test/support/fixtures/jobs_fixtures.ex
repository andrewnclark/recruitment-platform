defmodule Recruitment.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Recruitment.Jobs` context.
  """

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        title: "Software Engineer",
        description: "Building awesome software",
        requirements: "Elixir experience",
        location: "Remote",
        salary: "$100k-$150k"
      })
      |> Recruitment.Jobs.create_job()

    job
  end
end
