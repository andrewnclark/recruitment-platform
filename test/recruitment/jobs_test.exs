defmodule Recruitment.JobsTest do
  use Recruitment.DataCase

  alias Recruitment.Jobs

  describe "jobs" do
    alias Recruitment.Jobs.Job

    import Recruitment.JobsFixtures

    @invalid_attrs %{title: nil, description: nil, requirements: nil, location: nil, salary: nil}

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      valid_attrs = %{
        title: "Software Engineer", 
        description: "Building awesome software", 
        requirements: "Elixir experience", 
        location: "Remote", 
        salary: "$100k-$150k"
      }

      assert {:ok, %Job{} = job} = Jobs.create_job(valid_attrs)
      assert job.title == "Software Engineer"
      assert job.description == "Building awesome software"
      assert job.requirements == "Elixir experience"
      assert job.location == "Remote"
      assert job.salary == "$100k-$150k"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      update_attrs = %{
        title: "Senior Software Engineer", 
        description: "Leading a team", 
        requirements: "5+ years Elixir experience", 
        location: "Hybrid", 
        salary: "$150k-$200k"
      }

      assert {:ok, %Job{} = job} = Jobs.update_job(job, update_attrs)
      assert job.title == "Senior Software Engineer"
      assert job.description == "Leading a team"
      assert job.requirements == "5+ years Elixir experience"
      assert job.location == "Hybrid"
      assert job.salary == "$150k-$200k"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end
  end
end
