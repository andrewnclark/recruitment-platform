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
alias Recruitment.Applications.Application

# Clear existing data
IO.puts("Clearing existing data...")
Repo.delete_all(Application)
Repo.delete_all(Job)

IO.puts("Creating sample jobs...")

# Create sample jobs with job_type and slug fields
jobs = [
  %{
    title: "Elixir Developer",
    description: "We are looking for an experienced Elixir developer to join our team. You will be responsible for building and maintaining high-performance web applications using Elixir and Phoenix Framework.\n\nYou'll work in an agile environment with a focus on delivering clean, maintainable code.",
    summary: "Experienced Elixir developer needed to build high-performance web applications using Phoenix Framework.",
    requirements: "- 2+ years of experience with Elixir and Phoenix Framework\n- Strong understanding of functional programming concepts\n- Experience with PostgreSQL or other relational databases\n- Knowledge of front-end technologies (HTML, CSS, JavaScript)\n- Good communication skills and ability to work in a team",
    location: "London",
    salary: "£60,000 - £80,000",
    job_type: "full_time",
    slug: "elixir-developer",
    category: "engineering"
  },
  %{
    title: "Senior Backend Engineer",
    description: "Join our engineering team to help build scalable backend systems. You'll be working on critical infrastructure that powers our platform used by millions of users worldwide.\n\nThis is a remote position with occasional travel to our headquarters for team meetings.",
    summary: "Senior engineer needed to build and maintain scalable backend systems for our platform.",
    requirements: "- 5+ years of experience in backend development\n- Proficiency in at least one functional programming language (Elixir, Erlang, Haskell, etc.)\n- Experience with distributed systems and microservices architecture\n- Strong problem-solving skills and attention to detail\n- Experience with cloud platforms (AWS, GCP, or Azure)",
    location: "Remote",
    salary: "£80,000 - £100,000",
    job_type: "full_time",
    slug: "senior-backend-engineer",
    category: "engineering"
  },
  %{
    title: "Full Stack Developer",
    description: "We're seeking a talented Full Stack Developer to join our innovative team. You'll be involved in all aspects of development from database design to frontend implementation.\n\nYou'll have the opportunity to work on exciting projects and contribute to the growth of our company.",
    summary: "Full Stack Developer needed for end-to-end web application development.",
    requirements: "- 3+ years of experience in full stack development\n- Experience with Elixir/Phoenix or willingness to learn\n- Proficiency in JavaScript and modern frontend frameworks (React, Vue, etc.)\n- Knowledge of database design and optimization\n- Experience with version control systems (Git)",
    location: "Manchester",
    salary: "£55,000 - £75,000",
    job_type: "full_time",
    slug: "full-stack-developer",
    category: "engineering"
  },
  %{
    title: "DevOps Engineer",
    description: "As a DevOps Engineer, you'll be responsible for maintaining and improving our infrastructure. You'll work closely with development teams to automate deployment processes and ensure system reliability.\n\nYou'll play a key role in our continuous integration and delivery pipeline.",
    summary: "DevOps Engineer needed to maintain and improve our infrastructure and deployment processes.",
    requirements: "- 3+ years of experience in DevOps or similar role\n- Experience with containerization (Docker, Kubernetes)\n- Knowledge of infrastructure as code (Terraform, CloudFormation)\n- Experience with CI/CD pipelines\n- Strong scripting skills (Bash, Python, etc.)",
    location: "Edinburgh",
    salary: "£65,000 - £85,000",
    job_type: "full_time",
    slug: "devops-engineer",
    category: "operations"
  },
  %{
    title: "UI/UX Designer (Part-Time)",
    description: "We're looking for a creative UI/UX Designer to join our team on a part-time basis. You'll be responsible for creating intuitive and visually appealing user interfaces for our web applications.\n\nYou'll collaborate with product managers and developers to deliver exceptional user experiences.",
    summary: "Part-time UI/UX Designer needed to create intuitive and visually appealing interfaces.",
    requirements: "- 2+ years of experience in UI/UX design\n- Proficiency in design tools (Figma, Sketch, Adobe XD)\n- Understanding of user-centered design principles\n- Portfolio demonstrating your design skills\n- Experience with web accessibility standards",
    location: "London",
    salary: "£35,000 - £45,000 (pro-rata)",
    job_type: "part_time",
    slug: "ui-ux-designer-part-time",
    category: "design"
  },
  %{
    title: "Data Scientist (Contract)",
    description: "We're seeking a Data Scientist for a 6-month contract to help analyze our customer data and develop predictive models. You'll work with our data engineering team to extract insights that drive business decisions.\n\nThis is an excellent opportunity to work on challenging problems with a large dataset.",
    summary: "Contract Data Scientist needed to analyze customer data and develop predictive models.",
    requirements: "- MSc or PhD in a quantitative field\n- Experience with machine learning and statistical analysis\n- Proficiency in Python and data science libraries (pandas, scikit-learn, etc.)\n- Knowledge of SQL and database concepts\n- Strong communication skills to present findings to non-technical stakeholders",
    location: "Remote",
    salary: "£500 - £600 per day",
    job_type: "contract",
    slug: "data-scientist-contract",
    category: "data"
  }
]

# Insert jobs and store their IDs
job_ids = Enum.map(jobs, fn job_attrs ->
  {:ok, job} = Recruitment.Jobs.create_job(job_attrs)
  job.id
end)

IO.puts("Created #{length(job_ids)} jobs")

# Sample resume text for testing CV summarization
sample_resume_1 = """
# John Smith
**Senior Software Engineer**
john.smith@example.com | +44 7123 456789 | London, UK

## Professional Summary
Experienced software engineer with 8+ years of expertise in building scalable web applications. Specialized in Elixir/Phoenix and distributed systems. Passionate about functional programming and creating high-performance, maintainable code.

## Skills
- **Languages**: Elixir, JavaScript, Python, Ruby
- **Frameworks**: Phoenix, React, Node.js, Django
- **Databases**: PostgreSQL, MongoDB, Redis
- **Tools**: Git, Docker, Kubernetes, AWS, CI/CD pipelines
- **Methodologies**: Agile, TDD, BDD, Microservices

## Work Experience
### Senior Backend Engineer at TechCorp (2022-Present)
- Led a team of 5 engineers to redesign the company's payment processing system using Elixir/OTP
- Improved system throughput by 300% while reducing infrastructure costs by 40%
- Implemented comprehensive test coverage, achieving 95% code coverage
- Mentored junior developers and established coding standards

### Software Engineer at WebSolutions (2019-2022)
- Developed and maintained multiple client applications using Phoenix Framework
- Created a real-time analytics dashboard using Phoenix Channels and LiveView
- Optimized database queries, reducing average response time by 60%
- Collaborated with UX designers to implement responsive frontend interfaces

### Junior Developer at StartupX (2017-2019)
- Built RESTful APIs using Ruby on Rails
- Participated in daily stand-ups and sprint planning
- Implemented automated testing for critical business logic

## Education
**MSc in Computer Science** - University of London (2016-2017)
**BSc in Software Engineering** - University of Manchester (2013-2016)

## Projects
- **EventHub**: Open-source event sourcing library for Elixir (1000+ GitHub stars)
- **DataFlow**: Real-time data processing pipeline using GenStage and Flow
"""

sample_resume_2 = """
# Emily Johnson
**Full Stack Developer**
emily.johnson@example.com | +44 7987 654321 | Manchester, UK

## Summary
Creative and detail-oriented Full Stack Developer with 5 years of experience building modern web applications. Proficient in both frontend and backend technologies with a passion for creating intuitive user experiences and robust server architectures.

## Technical Skills
- **Frontend**: HTML5, CSS3, JavaScript (ES6+), React, Vue.js, TypeScript
- **Backend**: Node.js, Express, Elixir, Phoenix, Python, Django
- **Databases**: PostgreSQL, MySQL, MongoDB
- **DevOps**: Docker, AWS, Heroku, CI/CD, Git
- **Testing**: Jest, Cypress, ExUnit

## Professional Experience
### Full Stack Developer at InnovateX (2022-Present)
- Developed and maintained multiple client-facing applications using React and Node.js
- Implemented a microservice architecture that improved system scalability
- Created a design system that ensured consistent UI across all company products
- Reduced page load times by 40% through code optimization and lazy loading

### Frontend Developer at TechStart (2020-2022)
- Built responsive web interfaces using React and Redux
- Collaborated with UX designers to implement pixel-perfect designs
- Integrated RESTful APIs and GraphQL endpoints
- Participated in code reviews and pair programming sessions

### Junior Web Developer at DigitalCraft (2018-2020)
- Developed and maintained client websites using HTML, CSS, and JavaScript
- Created WordPress themes and plugins for content management
- Assisted in database design and implementation
- Provided technical support to clients

## Education
**BSc in Computer Science** - University of Bristol (2015-2018)
- First Class Honours
- Final Year Project: "Accessibility in Modern Web Applications"

## Personal Projects
- **TaskFlow**: A productivity application built with React and Firebase
- **RecipeDB**: A recipe management system using Elixir and Phoenix
- **WeatherNow**: A real-time weather application with geolocation features

## Languages
- English (Native)
- French (Intermediate)
- Spanish (Basic)
"""

sample_resume_3 = """
# Michael Chen
**DevOps Engineer**
michael.chen@example.com | +44 7654 321987 | Edinburgh, UK

## Professional Summary
Results-driven DevOps Engineer with 6+ years of experience automating and optimizing mission-critical deployments in AWS and on-premises environments. Skilled in CI/CD, infrastructure as code, and container orchestration.

## Technical Skills
- **Cloud Platforms**: AWS (Certified Solutions Architect), GCP, Azure
- **Containerization**: Docker, Kubernetes, ECS
- **Infrastructure as Code**: Terraform, CloudFormation, Ansible
- **CI/CD**: Jenkins, GitHub Actions, GitLab CI, CircleCI
- **Monitoring**: Prometheus, Grafana, ELK Stack, Datadog
- **Scripting**: Bash, Python, Go
- **Version Control**: Git, GitHub, GitLab

## Professional Experience
### Senior DevOps Engineer at CloudScale (2022-Present)
- Designed and implemented a Kubernetes-based microservices platform for 20+ applications
- Reduced deployment time from hours to minutes with automated CI/CD pipelines
- Created comprehensive monitoring and alerting systems that improved incident response time by 70%
- Implemented infrastructure as code using Terraform, achieving 100% environment parity

### DevOps Engineer at TechSolutions (2019-2022)
- Migrated legacy applications to containerized environments using Docker
- Automated infrastructure provisioning with Terraform and AWS CloudFormation
- Implemented blue-green deployment strategies to minimize downtime
- Collaborated with development teams to optimize application performance

### Systems Administrator at DataCorp (2017-2019)
- Managed on-premises infrastructure including Linux and Windows servers
- Implemented backup and disaster recovery solutions
- Automated routine tasks using Bash and Python scripts
- Provided technical support to internal teams

## Education
**MSc in Cloud Computing** - University of Edinburgh (2016-2017)
**BSc in Computer Networks** - University of Glasgow (2013-2016)

## Certifications
- AWS Certified Solutions Architect – Professional
- Certified Kubernetes Administrator (CKA)
- HashiCorp Certified Terraform Associate
- Linux Professional Institute Certification (LPIC-1)

## Projects
- **InfraCode**: Open-source Terraform modules for common AWS patterns (500+ GitHub stars)
- **K8s-Monitor**: Custom Kubernetes monitoring solution with Prometheus and Grafana
- **Auto-Scale**: Predictive auto-scaling solution for AWS workloads
"""

IO.puts("Creating sample applications...")

# Create sample applications with different statuses
applications = [
  %{
    first_name: "John",
    last_name: "Smith",
    email: "john.smith@example.com",
    phone: "+44 7123 456789",
    cover_letter: "I am excited to apply for the Elixir Developer position at your company. With over 8 years of experience in software development and a strong focus on Elixir and Phoenix, I believe I would be a valuable addition to your team.",
    resume: "https://example.com/john_smith_resume.pdf",
    resume_text: sample_resume_1,
    status: "submitted",
    job_id: Enum.at(job_ids, 0),
    summary_status: "pending"
  },
  %{
    first_name: "Emily",
    last_name: "Johnson",
    email: "emily.johnson@example.com",
    phone: "+44 7987 654321",
    cover_letter: "I am writing to express my interest in the Full Stack Developer position. With 5 years of experience in both frontend and backend development, I am confident in my ability to contribute to your team's success.",
    resume: "https://example.com/emily_johnson_resume.pdf",
    resume_text: sample_resume_2,
    status: "reviewed",
    job_id: Enum.at(job_ids, 2),
    summary_status: "pending"
  },
  %{
    first_name: "Michael",
    last_name: "Chen",
    email: "michael.chen@example.com",
    phone: "+44 7654 321987",
    cover_letter: "I am applying for the DevOps Engineer position at your company. With my extensive experience in cloud infrastructure, containerization, and CI/CD pipelines, I am well-equipped to help optimize your deployment processes.",
    resume: "https://example.com/michael_chen_resume.pdf",
    resume_text: sample_resume_3,
    status: "interviewed",
    job_id: Enum.at(job_ids, 3),
    summary_status: "pending"
  }
]

# Insert applications
application_ids = Enum.map(applications, fn app_attrs ->
  {:ok, application} = Recruitment.Applications.create_application(app_attrs)
  application.id
end)

IO.puts("Created #{length(application_ids)} applications")
IO.puts("Seed data creation complete!")

# Generate a CV summary for one application to demonstrate the feature
IO.puts("Generating a sample CV summary...")
application = Recruitment.Applications.get_application!(Enum.at(application_ids, 0))
{:ok, _job} = Recruitment.Applications.request_cv_summarization(application)

IO.puts("Seed script completed successfully!")
