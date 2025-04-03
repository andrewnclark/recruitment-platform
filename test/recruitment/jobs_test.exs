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
    
    test "get_job_by_location_and_slug/2 returns the job with given location and slug" do
      job = job_fixture(%{location: "London", title: "Software Engineer"})
      assert Jobs.get_job_by_location_and_slug("london", job.slug) == job
    end
    
    test "get_job_by_location_and_slug/2 is case insensitive for location" do
      job = job_fixture(%{location: "London", title: "Software Engineer"})
      assert Jobs.get_job_by_location_and_slug("LONDON", job.slug) == job
      assert Jobs.get_job_by_location_and_slug("london", job.slug) == job
      assert Jobs.get_job_by_location_and_slug("LonDon", job.slug) == job
    end
    
    test "get_job_by_location_and_slug/2 returns nil when no job matches" do
      assert Jobs.get_job_by_location_and_slug("nonexistent", "invalid-slug") == nil
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
      assert job.slug == "software-engineer"
    end
    
    test "create_job/1 generates slug from title" do
      attrs = %{title: "Senior Ruby Developer", description: "Ruby development", location: "Berlin"}
      assert {:ok, %Job{} = job} = Jobs.create_job(attrs)
      assert job.slug == "senior-ruby-developer"
    end
    
    test "create_job/1 handles special characters in slug generation" do
      attrs = %{title: "C++ & Java Developer!", description: "Programming", location: "Paris"}
      assert {:ok, %Job{} = job} = Jobs.create_job(attrs)
      assert job.slug == "c-java-developer"
    end
    
    test "create_job/1 handles whitespace in slug generation" do
      attrs = %{title: "  Data   Scientist  ", description: "Data analysis", location: "Berlin"}
      assert {:ok, %Job{} = job} = Jobs.create_job(attrs)
      assert job.slug == "data-scientist"
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
      assert job.slug == "senior-software-engineer"
    end
    
    test "update_job/2 updates slug when title changes" do
      job = job_fixture(%{title: "Developer"})
      assert job.slug == "developer"
      
      {:ok, updated_job} = Jobs.update_job(job, %{title: "Senior Developer"})
      assert updated_job.slug == "senior-developer"
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
  
  describe "job slug uniqueness" do
    alias Recruitment.Jobs.Job
    import Recruitment.JobsFixtures
    
    test "jobs with identical titles have unique slugs" do
      # Create first job
      {:ok, job1} = Jobs.create_job(%{
        title: "Software Engineer",
        description: "First job description",
        location: "London"
      })
      
      # Create second job with same title
      {:ok, job2} = Jobs.create_job(%{
        title: "Software Engineer",
        description: "Second job description",
        location: "Berlin"
      })
      
      # Slugs should be different now that we've implemented uniqueness
      refute job1.slug == job2.slug
      
      # Both slugs should start with the same base
      assert String.starts_with?(job2.slug, "software-engineer-")
    end
    
    test "updating a job maintains the same slug if title doesn't change" do
      {:ok, job} = Jobs.create_job(%{
        title: "DevOps Engineer",
        description: "Original description",
        location: "Remote"
      })
      
      original_slug = job.slug
      
      {:ok, updated_job} = Jobs.update_job(job, %{
        description: "Updated description"
      })
      
      assert updated_job.slug == original_slug
    end
    
    test "slug doesn't change when title is updated" do
      # Create a job
      {:ok, job} = Jobs.create_job(%{
        title: "Frontend Developer",
        description: "Original description",
        location: "Remote",
        job_type: "full_time",
        category: "Engineering",
        summary: "A frontend role"
      })
      
      original_slug = job.slug
      
      # Update the job title
      {:ok, updated_job} = Jobs.update_job(job, %{
        title: "Senior Frontend Developer"
      })
      
      # Slug should remain the same
      assert updated_job.slug == original_slug
      assert updated_job.title == "Senior Frontend Developer"
    end
    
    test "slug can be regenerated when explicitly requested" do
      # Create a job
      {:ok, job} = Jobs.create_job(%{
        title: "Backend Developer",
        description: "Original description",
        location: "Remote",
        job_type: "full_time",
        category: "Engineering",
        summary: "A backend role"
      })
      
      original_slug = job.slug
      
      # Update the job title but keep the original slug
      {:ok, updated_job} = Jobs.update_job(job, %{
        title: "Senior Backend Developer"
      })
      
      # Slug should remain the same
      assert updated_job.slug == original_slug
      
      # Now explicitly regenerate the slug
      {:ok, regenerated_job} = Jobs.regenerate_job_slug(updated_job)
      
      # Slug should be updated to match the new title
      assert regenerated_job.slug != original_slug
      assert regenerated_job.slug == "senior-backend-developer"
    end
    
    test "regenerate_job_slug/2 updates both the slug and other attributes" do
      # Create a job
      {:ok, job} = Jobs.create_job(%{
        title: "Product Manager",
        description: "Original description",
        location: "Remote",
        job_type: "full_time",
        category: "Product",
        summary: "A product role"
      })
      
      # Update multiple attributes and regenerate slug
      {:ok, updated_job} = Jobs.regenerate_job_slug(job, %{
        title: "Senior Product Manager",
        description: "Updated description",
        location: "Hybrid"
      })
      
      # Both slug and other attributes should be updated
      assert updated_job.slug == "senior-product-manager"
      assert updated_job.description == "Updated description"
      assert updated_job.location == "Hybrid"
    end
    
    test "slug uniqueness is preserved when updating a job title" do
      # Create two jobs with different titles
      {:ok, job1} = Jobs.create_job(%{
        title: "Frontend Developer",
        description: "Job 1",
        location: "Berlin"
      })
      
      {:ok, job2} = Jobs.create_job(%{
        title: "Backend Developer",
        description: "Job 2",
        location: "Munich"
      })
      
      # Update job2 to have the same title as job1
      {:ok, updated_job2} = Jobs.update_job(job2, %{title: "Frontend Developer"})
      
      # Slugs should be different
      refute job1.slug == updated_job2.slug
      assert String.starts_with?(updated_job2.slug, "frontend-developer-")
    end
  end
end
