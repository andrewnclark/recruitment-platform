defmodule Recruitment.AI.TestHelper do
  @moduledoc """
  Helper functions for testing and demonstrating the AI capabilities
  in development and test environments.
  """
  
  alias Recruitment.Applications
  alias Recruitment.Repo
  alias Recruitment.Applications.Application
  alias Recruitment.AI.CVSummarizer
  
  @doc """
  Loads sample resume text for testing summarization.
  
  Returns resume text as a string.
  """
  def load_sample_resume do
    """
    JANE SMITH
    Software Engineer

    CONTACT
    Email: jane.smith@example.com
    Phone: (555) 123-4567
    Location: San Francisco, CA
    LinkedIn: linkedin.com/in/janesmith

    SUMMARY
    Experienced software engineer with 7+ years of experience in web development 
    and distributed systems. Proficient in Elixir, JavaScript, and Python with 
    a focus on building scalable, maintainable applications.

    EXPERIENCE
    Senior Software Engineer | TechCorp Inc. | 2020-Present
    • Led development of a high-throughput distributed messaging system using Elixir/Phoenix
    • Designed and implemented RESTful and GraphQL APIs serving 100k+ daily active users
    • Mentored junior engineers and conducted code reviews to ensure code quality
    • Reduced API response times by 40% through caching strategies and query optimization

    Software Engineer | Startup Innovations | 2017-2020
    • Built real-time collaboration features using WebSockets and Phoenix Channels
    • Implemented CI/CD pipelines that reduced deployment time from hours to minutes
    • Contributed to open-source projects in the Elixir ecosystem
    • Improved test coverage from 60% to 90%, significantly reducing bugs in production

    SKILLS
    • Languages: Elixir, JavaScript, Python, SQL, TypeScript
    • Frameworks: Phoenix, React, Node.js, Flask
    • Databases: PostgreSQL, MongoDB, Redis
    • Tools: Git, Docker, AWS, Kubernetes, CI/CD

    EDUCATION
    Master of Computer Science
    Stanford University | 2015-2017

    Bachelor of Science in Computer Engineering
    University of California, Berkeley | 2011-2015

    PROJECTS
    Open Source Contribution: Ecto Extensions
    • Developed and maintained a library of Ecto extensions for advanced query capabilities
    • 500+ GitHub stars, used by multiple production applications

    Personal Project: Distributed Task Scheduler
    • Built a fault-tolerant distributed task scheduler in Elixir
    • Implemented custom consistency protocols for reliability across node failures
    """
  end
  
  @doc """
  Test the CV summarizer with the sample resume.
  
  Prints the summary to the console.
  """
  def test_summarizer do
    resume = load_sample_resume()
    
    IO.puts("\n==== TESTING CV SUMMARIZER ====\n")
    IO.puts("Sample Resume Length: #{String.length(resume)} characters")
    
    case CVSummarizer.summarize(resume) do
      {:ok, summary} ->
        IO.puts("\n==== GENERATED SUMMARY ====\n")
        IO.puts(summary)
        IO.puts("\nSummary Length: #{String.length(summary)} characters")
        IO.puts("Compression Ratio: #{Float.round(String.length(summary) / String.length(resume) * 100, 1)}%")
        
        {:ok, summary}
        
      {:error, reason} ->
        IO.puts("\n==== ERROR ====\n")
        IO.puts("Failed to generate summary: #{reason}")
        
        {:error, reason}
    end
  end
  
  @doc """
  Creates a test application with a resume and generates a summary for it.
  
  Returns the created application.
  """
  def create_test_application_with_summary do
    # Create a job
    {:ok, job} = Recruitment.Jobs.create_job(%{
      title: "Senior Software Engineer", 
      description: "We are looking for a senior software engineer with Elixir experience.",
      location: "Remote"
    })
    
    # Create an application
    {:ok, application} = Applications.create_application(%{
      first_name: "Jane",
      last_name: "Smith",
      email: "jane.smith@example.com",
      phone: "555-123-4567",
      resume: "test_resume.pdf",
      job_id: job.id
    })
    
    # Update the application with the sample resume text
    # In a real app, this would be extracted from the resume file
    resume_text = load_sample_resume()
    
    # Generate a summary
    {:ok, summary} = CVSummarizer.summarize(resume_text)
    
    # Update the application with the summary
    {:ok, updated_application} = Applications.update_application(application, %{
      cv_summary: summary,
      summary_status: "completed"
    })
    
    IO.puts("\n==== TEST APPLICATION CREATED ====\n")
    IO.puts("ID: #{updated_application.id}")
    IO.puts("Name: #{updated_application.first_name} #{updated_application.last_name}")
    IO.puts("Job: #{job.title}")
    IO.puts("Summary Status: #{updated_application.summary_status}")
    IO.puts("\n==== SUMMARY ====\n")
    IO.puts(updated_application.cv_summary)
    
    updated_application
  end
  
  @doc """
  Gets all applications with their CV summaries.
  
  Useful for debugging and development.
  """
  def list_applications_with_summaries do
    applications = Repo.all(Application)
    |> Repo.preload(:job)
    
    IO.puts("\n==== APPLICATIONS WITH SUMMARIES ====\n")
    
    Enum.each(applications, fn app ->
      IO.puts("ID: #{app.id}")
      IO.puts("Name: #{app.first_name} #{app.last_name}")
      IO.puts("Job: #{app.job.title}")
      IO.puts("Summary Status: #{app.summary_status}")
      
      if app.cv_summary do
        IO.puts("Has summary: Yes")
      else
        IO.puts("Has summary: No")
      end
      
      IO.puts("---")
    end)
    
    applications
  end
end
