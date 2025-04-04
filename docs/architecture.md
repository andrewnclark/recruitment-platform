# Architecture and Context Design

## Overview

The Recruitment Platform is built using a domain-driven design approach with clear separation of concerns. The application is structured around several key contexts that encapsulate specific business domains, making the codebase modular, maintainable, and scalable.

## Multi-Domain Architecture

The application employs a multi-domain architecture with three distinct interfaces:

1. **Main Site** (`domain.com`)
   - Public-facing website for job listings and company information
   - Primary entry point for potential applicants

2. **Application Portal** (`apply.domain.com`)
   - Dedicated subdomain for job applications
   - Streamlined interface for applicants to submit their information

3. **Admin Interface** (`admin.domain.com`)
   - Secure area for recruiters and hiring managers
   - Tools for managing job listings and processing applications

This separation provides several benefits:
- Clear user journeys for different user types
- Enhanced security through domain isolation
- Ability to scale and optimize each domain independently

## Core Contexts

### Jobs Context

The Jobs context is responsible for all aspects of job listings management:

```elixir
defmodule Recruitment.Jobs do
  # Job-related functionality
end
```

**Key Features:**
- CRUD operations for job listings
- Categorization and tagging
- Location-based job filtering
- Slug generation for SEO-friendly URLs

**Design Decisions:**
- Implemented unique slug generation with random suffixes to handle duplicate job titles
- Created a specialized `get_job_by_location_and_slug/2` function for efficient URL-based lookups
- Structured jobs with comprehensive metadata for better searchability

### Applications Context

The Applications context handles the entire application lifecycle:

```elixir
defmodule Recruitment.Applications do
  # Application-related functionality
end
```

**Key Features:**
- Application submission and processing
- Status tracking (submitted, reviewed, interviewed, etc.)
- CV and document management
- Integration with the AI context for CV summarization

**Design Decisions:**
- Separated application logic from job listings for cleaner code organization
- Implemented comprehensive validation for applicant data
- Created a flexible status system for tracking application progress

### AI Context

The AI context provides machine learning capabilities to enhance the recruitment process:

```elixir
defmodule Recruitment.AI do
  # AI-related functionality
end
```

**Key Features:**
- CV summarization using natural language processing
- Text extraction and analysis
- Integration with Bumblebee for NLP tasks

**Design Decisions:**
- Implemented the CV summarizer as a service module for better testability
- Used the facebook/bart-large-cnn model for high-quality summarization
- Created a mock implementation for development and testing environments

### Workers Context

The Workers context manages background job processing:

```elixir
defmodule Recruitment.Workers do
  # Background job processing
end
```

**Key Features:**
- Asynchronous processing of resource-intensive tasks
- Job scheduling and monitoring
- Failure handling and retries

**Design Decisions:**
- Utilized Oban for reliable background job processing
- Implemented PubSub for real-time updates on job completion
- Designed workers to be idempotent for reliability

## Why This Architecture?

This architecture was chosen for several reasons:

1. **Separation of Concerns**: Each context has a clear responsibility, making the code easier to understand and maintain.

2. **Scalability**: The modular design allows different parts of the system to scale independently based on demand.

3. **Testability**: Isolated contexts with clear boundaries make testing more straightforward and reliable.

4. **Flexibility**: New features can be added to specific contexts without affecting the entire system.

5. **User Experience**: The multi-domain approach provides tailored experiences for different user types.

## Context Relationships

The contexts interact in well-defined ways:

- **Jobs → Applications**: Applications reference jobs through foreign keys
- **Applications → AI**: The AI context provides services to enhance application processing
- **AI → Workers**: Resource-intensive AI tasks are delegated to background workers
- **Workers → PubSub**: Workers broadcast updates to the UI through Phoenix PubSub

This architecture ensures a clean separation while allowing for necessary collaboration between domains.
