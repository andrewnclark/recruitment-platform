# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Recruitment.Repo.insert!(%Recruitment.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Recruitment.Repo
alias Recruitment.Jobs.Job

# Clear existing jobs
Repo.delete_all(Job)

# Create sample jobs
[
  %{
    title: "Elixir Developer",
    description: "We are looking for an experienced Elixir developer to join our team. You will be responsible for building and maintaining high-performance web applications using Elixir and Phoenix Framework.\n\nYou'll work in an agile environment with a focus on delivering clean, maintainable code.",
    requirements: "- 2+ years of experience with Elixir and Phoenix Framework\n- Strong understanding of functional programming concepts\n- Experience with PostgreSQL or other relational databases\n- Knowledge of front-end technologies (HTML, CSS, JavaScript)\n- Good communication skills and ability to work in a team",
    location: "London",
    salary: "£60,000 - £80,000"
  },
  %{
    title: "Senior Backend Engineer",
    description: "Join our engineering team to help build scalable backend systems. You'll be working on critical infrastructure that powers our platform used by millions of users worldwide.\n\nThis is a remote position with occasional travel to our headquarters for team meetings.",
    requirements: "- 5+ years of experience in backend development\n- Proficiency in at least one functional programming language (Elixir, Erlang, Haskell, etc.)\n- Experience with distributed systems and microservices architecture\n- Strong problem-solving skills and attention to detail\n- Experience with cloud platforms (AWS, GCP, or Azure)",
    location: "Remote",
    salary: "£80,000 - £100,000"
  },
  %{
    title: "Full Stack Developer",
    description: "We're seeking a talented Full Stack Developer to join our innovative team. You'll be involved in all aspects of development from database design to frontend implementation.\n\nYou'll have the opportunity to work on exciting projects and contribute to the growth of our company.",
    requirements: "- 3+ years of experience in full stack development\n- Experience with Elixir/Phoenix or willingness to learn\n- Proficiency in JavaScript and modern frontend frameworks (React, Vue, etc.)\n- Knowledge of database design and optimization\n- Experience with version control systems (Git)",
    location: "Manchester",
    salary: "£55,000 - £75,000"
  },
  %{
    title: "DevOps Engineer",
    description: "As a DevOps Engineer, you'll be responsible for maintaining and improving our infrastructure. You'll work closely with development teams to automate deployment processes and ensure system reliability.\n\nYou'll play a key role in our continuous integration and delivery pipeline.",
    requirements: "- 3+ years of experience in DevOps or similar role\n- Experience with containerization (Docker, Kubernetes)\n- Knowledge of infrastructure as code (Terraform, CloudFormation)\n- Experience with CI/CD pipelines\n- Strong scripting skills (Bash, Python, etc.)",
    location: "Edinburgh",
    salary: "£65,000 - £85,000"
  },
  %{
    title: "QA Engineer",
    description: "We are looking for a detail-oriented QA Engineer to ensure the quality of our products. You'll be responsible for developing and executing test plans, identifying bugs, and working with developers to resolve issues.\n\nYou'll help maintain our high standards of software quality.",
    requirements: "- 2+ years of experience in software testing\n- Experience with automated testing frameworks\n- Knowledge of testing methodologies and best practices\n- Strong analytical and problem-solving skills\n- Good communication and documentation skills",
    location: "Bristol",
    salary: "£45,000 - £60,000"
  }
]
|> Enum.each(fn job_data ->
  %Job{}
  |> Job.changeset(job_data)
  |> Repo.insert!()
end)

IO.puts("Database seeded with sample jobs!")
