# Recruitment Platform

A modern, AI-enhanced recruitment platform built with Elixir and Phoenix, designed to streamline the hiring process for both recruiters and applicants.

## Features

- **Job Listings Management**: Create, update, and manage job postings with location-based routing
- **Application Processing**: Handle job applications with comprehensive tracking and status management
- **AI-Powered CV Summarization**: Automatically generate concise summaries of applicant CVs using NLP
- **Multi-Domain Architecture**: Separate domains for main site, application portal, and admin interface
- **Real-time Updates**: Leverage Phoenix PubSub for instant notifications and live updates
- **Background Processing**: Utilize Oban for efficient handling of resource-intensive tasks

## System Requirements

- Elixir 1.14+
- Phoenix 1.7+
- PostgreSQL 13+
- Node.js 14+ (for asset compilation)

## Getting Started

### Setup and Installation

```bash
# Clone the repository
git clone https://github.com/your-org/recruitment.git
cd recruitment

# Install dependencies
mix setup

# Create and migrate the database
mix ecto.setup

# Start the Phoenix server
mix phx.server
```

Now you can visit the application at:
- Main site: [`localhost:4000`](http://localhost:4000)
- Application portal: [`apply.localhost:4000`](http://apply.localhost:4000)
- Admin interface: [`admin.localhost:4000`](http://admin.localhost:4000)

### Environment Configuration

Create a `.env` file in the root directory with the following variables:

```
DATABASE_URL=postgres://postgres:postgres@localhost/recruitment_dev
SECRET_KEY_BASE=your_secret_key_base
```

## Architecture

The application is structured around several key contexts:

- **Jobs**: Manages job listings, categories, and search functionality
- **Applications**: Handles job applications, statuses, and applicant data
- **AI**: Provides AI capabilities like CV summarization using Bumblebee
- **Workers**: Background job processing for resource-intensive tasks

For more detailed documentation, see the [docs directory](./docs).

## Testing

```bash
# Run all tests
mix test

# Run specific test files
mix test test/recruitment/applications_test.exs
```

## Deployment

The application is configured for deployment on standard Phoenix hosting platforms:

```bash
# Build the release
MIX_ENV=prod mix release

# Start the release
_build/prod/rel/recruitment/bin/recruitment start
```

See the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html) for more information.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
