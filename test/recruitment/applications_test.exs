defmodule Recruitment.ApplicationsTest do
  use Recruitment.DataCase

  alias Recruitment.Applications
  alias Recruitment.Applications.Application
  alias Recruitment.Jobs

  describe "applications" do
    import Recruitment.ApplicationsFixtures
    import Recruitment.JobsFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, email: nil, job_id: nil}

    test "list_applications/0 returns all applications" do
      application = application_fixture()
      assert Applications.list_applications() == [application]
    end

    test "get_application!/1 returns the application with given id" do
      application = application_fixture()
      assert Applications.get_application!(application.id) == application
    end

    test "create_application/1 with valid data creates an application" do
      job = job_fixture()

      valid_attrs = %{
        first_name: "Jane",
        last_name: "Smith",
        email: "jane.smith@example.com",
        phone: "555-987-6543",
        cover_letter: "I would like to apply for this position.",
        resume: "jane_resume.pdf",
        job_id: job.id
      }

      assert {:ok, %Application{} = application} = Applications.create_application(valid_attrs)
      assert application.first_name == "Jane"
      assert application.last_name == "Smith"
      assert application.email == "jane.smith@example.com"
      assert application.phone == "555-987-6543"
      assert application.cover_letter == "I would like to apply for this position."
      assert application.resume == "jane_resume.pdf"
      assert application.job_id == job.id
      assert application.status == "submitted"
    end

    test "create_application/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Applications.create_application(@invalid_attrs)
    end

    test "create_application/1 validates email format" do
      job = job_fixture()
      
      invalid_email_attrs = %{
        first_name: "John",
        last_name: "Doe",
        email: "invalid-email",
        job_id: job.id
      }
      
      assert {:error, changeset} = Applications.create_application(invalid_email_attrs)
      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "update_application/2 with valid data updates the application" do
      application = application_fixture()
      update_attrs = %{
        first_name: "Updated",
        last_name: "Name",
        email: "updated.email@example.com",
        status: "reviewed"
      }

      assert {:ok, %Application{} = updated} = Applications.update_application(application, update_attrs)
      assert updated.first_name == "Updated"
      assert updated.last_name == "Name"
      assert updated.email == "updated.email@example.com"
      assert updated.status == "reviewed"
    end

    test "update_application/2 with invalid data returns error changeset" do
      application = application_fixture()
      assert {:error, %Ecto.Changeset{}} = Applications.update_application(application, @invalid_attrs)
      assert application == Applications.get_application!(application.id)
    end

    test "delete_application/1 deletes the application" do
      application = application_fixture()
      assert {:ok, %Application{}} = Applications.delete_application(application)
      assert_raise Ecto.NoResultsError, fn -> Applications.get_application!(application.id) end
    end

    test "change_application/1 returns an application changeset" do
      application = application_fixture()
      assert %Ecto.Changeset{} = Applications.change_application(application)
    end
  end

  describe "job relationship" do
    import Recruitment.ApplicationsFixtures
    import Recruitment.JobsFixtures

    test "applications are associated with jobs" do
      job = job_fixture(%{title: "Software Developer"})
      application = application_fixture(%{job_id: job.id})
      
      assert application.job_id == job.id
    end

    test "get_job_by_location_and_slug/2 returns the correct job" do
      job = job_fixture(%{title: "Data Scientist", location: "London"})
      
      found_job = Applications.get_job_by_location_and_slug("london", job.slug)
      assert found_job.id == job.id
      assert found_job.title == "Data Scientist"
    end

    test "get_job_by_location_and_slug/2 is case insensitive for location" do
      job = job_fixture(%{title: "UX Designer", location: "Berlin"})
      
      assert Applications.get_job_by_location_and_slug("BERLIN", job.slug).id == job.id
      assert Applications.get_job_by_location_and_slug("berlin", job.slug).id == job.id
      assert Applications.get_job_by_location_and_slug("BeRLiN", job.slug).id == job.id
    end

    test "get_job_by_location_and_slug/2 returns nil for non-existent job" do
      assert Applications.get_job_by_location_and_slug("nowhere", "nonexistent-job") == nil
    end
  end

  describe "application validation" do
    import Recruitment.ApplicationsFixtures
    import Recruitment.JobsFixtures

    test "requires first_name, last_name, email, and job_id" do
      job = job_fixture()
      
      # Missing first_name
      attrs = %{last_name: "Doe", email: "test@example.com", job_id: job.id}
      assert {:error, changeset} = Applications.create_application(attrs)
      assert %{first_name: ["can't be blank"]} = errors_on(changeset)
      
      # Missing last_name
      attrs = %{first_name: "John", email: "test@example.com", job_id: job.id}
      assert {:error, changeset} = Applications.create_application(attrs)
      assert %{last_name: ["can't be blank"]} = errors_on(changeset)
      
      # Missing email
      attrs = %{first_name: "John", last_name: "Doe", job_id: job.id}
      assert {:error, changeset} = Applications.create_application(attrs)
      assert %{email: ["can't be blank"]} = errors_on(changeset)
      
      # Missing job_id
      attrs = %{first_name: "John", last_name: "Doe", email: "test@example.com"}
      assert {:error, changeset} = Applications.create_application(attrs)
      assert %{job_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates email format" do
      job = job_fixture()
      
      # Invalid email formats
      invalid_emails = [
        "plainaddress",
        "@missingusername.com",
        "missing.domain@",
        "spaces in email@domain.com",
        "missing@.com"
      ]
      
      for invalid_email <- invalid_emails do
        attrs = %{
          first_name: "John",
          last_name: "Doe",
          email: invalid_email,
          job_id: job.id
        }
        
        assert {:error, changeset} = Applications.create_application(attrs)
        assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
      end
      
      # Valid email formats
      valid_emails = [
        "simple@example.com",
        "very.common@example.com",
        "disposable.style.email.with+symbol@example.com",
        "other.email-with-hyphen@example.com",
        "fully-qualified-domain@example.com",
        "user.name+tag+sorting@example.com",
        "example-indeed@strange-example.com"
      ]
      
      for valid_email <- valid_emails do
        attrs = %{
          first_name: "John",
          last_name: "Doe",
          email: valid_email,
          job_id: job.id
        }
        
        assert {:ok, %Application{}} = Applications.create_application(attrs)
      end
    end

    test "validates email length" do
      job = job_fixture()
      
      # Email that's too long (over 160 characters)
      long_email = String.duplicate("a", 150) <> "@example.com"
      
      attrs = %{
        first_name: "John",
        last_name: "Doe",
        email: long_email,
        job_id: job.id
      }
      
      assert {:error, changeset} = Applications.create_application(attrs)
      assert %{email: ["should be at most 160 character(s)"]} = errors_on(changeset)
    end
  end

  describe "application status" do
    import Recruitment.ApplicationsFixtures
    
    test "default status is 'submitted'" do
      application = application_fixture()
      assert application.status == "submitted"
    end
    
    test "status can be updated" do
      application = application_fixture()
      
      # Update to 'reviewed'
      {:ok, updated} = Applications.update_application(application, %{status: "reviewed"})
      assert updated.status == "reviewed"
      
      # Update to 'interviewed'
      {:ok, updated} = Applications.update_application(updated, %{status: "interviewed"})
      assert updated.status == "interviewed"
      
      # Update to 'rejected'
      {:ok, updated} = Applications.update_application(updated, %{status: "rejected"})
      assert updated.status == "rejected"
      
      # Update to 'hired'
      {:ok, updated} = Applications.update_application(updated, %{status: "hired"})
      assert updated.status == "hired"
    end
  end
end
