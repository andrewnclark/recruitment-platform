# CV Summarization Feature

## Overview

The CV summarization feature automatically generates concise summaries of applicant resumes, helping recruiters quickly assess candidate qualifications. This document provides a detailed explanation of the implementation, workflow, and technical components.

## Feature Highlights

- **On-demand Processing**: Summaries are generated when requested by admin users
- **AI-powered Analysis**: Uses the BART Large CNN model via Bumblebee for high-quality summarization
- **Real-time Updates**: Provides instant feedback on summarization progress
- **Background Processing**: Handles resource-intensive tasks asynchronously
- **Seamless Integration**: Embedded directly in the application view interface

## Architecture Components

### 1. CV Summarizer Module

The core AI functionality is implemented in the `CVSummarizer` module:

```elixir
defmodule Recruitment.AI.CVSummarizer do
  @moduledoc """
  Service module for summarizing CV/resume content using Bumblebee.
  """
  
  alias Bumblebee.Text
  alias Nx.Serving
  
  # Implementation details for loading models and summarizing text
end
```

This module:
- Loads and initializes the BART model
- Processes CV text to generate summaries
- Handles text cleaning and formatting
- Provides both real and mock implementations for different environments

### 2. Background Worker

The `CVSummarizationWorker` handles asynchronous processing:

```elixir
defmodule Recruitment.Workers.CVSummarizationWorker do
  use Oban.Worker
  
  alias Recruitment.Applications
  alias Recruitment.AI.CVSummarizer
  alias Phoenix.PubSub
  
  # Implementation for processing jobs and updating application records
end
```

This worker:
- Retrieves application data from the database
- Calls the CV summarizer to generate the summary
- Updates the application record with the result
- Broadcasts completion notifications via PubSub

### 3. LiveView Component

The `CvSummaryComponent` provides the user interface:

```elixir
defmodule RecruitmentWeb.Live.Components.CvSummaryComponent do
  use RecruitmentWeb, :live_component
  
  alias Recruitment.Applications
  alias Phoenix.PubSub
  
  # Implementation for rendering and handling user interactions
end
```

This component:
- Displays the current summarization status
- Provides controls for requesting summaries
- Renders the generated summary with Markdown formatting
- Subscribes to PubSub updates for real-time feedback

## Workflow

### 1. Request Initiation

When an admin clicks "Generate Summary":

```elixir
def handle_event("request_summary", _params, socket) do
  application = socket.assigns.application
  
  # Request CV summarization
  case Applications.request_cv_summarization(application) do
    {:ok, _job} ->
      # Update status immediately to show processing
      {:noreply, 
       socket
       |> assign(:summary_status, "processing")}
      
    {:error, _reason} ->
      {:noreply, 
       socket
       |> assign(:summary_status, "error")
       |> put_flash(:error, "Failed to start CV summarization")}
  end
end
```

### 2. Job Creation

The Applications context creates an Oban job:

```elixir
def request_cv_summarization(%Application{} = application) do
  %{application_id: application.id}
  |> Recruitment.Workers.CVSummarizationWorker.new()
  |> Oban.insert()
end
```

### 3. Background Processing

The worker processes the job asynchronously:

```elixir
@impl Oban.Worker
def perform(%Oban.Job{args: %{"application_id" => application_id}}) do
  # Retrieve the application
  application = Applications.get_application!(application_id)
  
  # Update status to processing
  Applications.update_application(application, %{summary_status: "processing"})
  
  # Generate the summary
  case CVSummarizer.summarize_cv(application.resume_text) do
    {:ok, summary} ->
      # Update the application with the summary
      {:ok, updated_application} = Applications.update_application(application, %{
        cv_summary: summary,
        summary_status: "completed"
      })
      
      # Broadcast the update
      PubSub.broadcast(
        Recruitment.PubSub,
        "application:#{application.id}:summary",
        {:cv_summary_updated, updated_application}
      )
      
      :ok
      
    {:error, reason} ->
      # Update status to error
      {:ok, updated_application} = Applications.update_application(application, %{
        summary_status: "error"
      })
      
      # Broadcast the update
      PubSub.broadcast(
        Recruitment.PubSub,
        "application:#{application.id}:summary",
        {:cv_summary_updated, updated_application}
      )
      
      {:error, reason}
  end
end
```

### 4. Real-time Updates

The LiveView component receives updates via PubSub:

```elixir
def handle_info({:cv_summary_updated, updated_application}, socket) do
  {:noreply, 
   socket
   |> assign(:summary_status, updated_application.summary_status)
   |> assign(:cv_summary, updated_application.cv_summary)}
end
```

## Database Schema

The Applications schema includes fields for storing summarization data:

```elixir
schema "applications" do
  # Other fields...
  field :cv_summary, :string
  field :summary_status, :string, default: "pending"
  
  timestamps()
end
```

## Implementation Considerations

### Performance

- The model loading is done once at application startup
- Summarization runs in a background job to prevent blocking the web server
- PubSub provides efficient real-time updates without polling

### Error Handling

- Failed summarization attempts update the status to "error"
- Users can retry failed summarizations
- Oban provides automatic retries for transient failures

### User Experience

- The component is embedded directly in the application view
- Status updates are shown in real-time
- The interface provides clear feedback on the current state

## Testing

The feature includes comprehensive tests:

```elixir
# Test for the CV summarizer
test "summarize_cv/1 returns a summary for valid input" do
  text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit..."
  assert {:ok, summary} = CVSummarizer.summarize_cv(text)
  assert is_binary(summary)
  assert String.length(summary) < String.length(text)
end

# Test for the worker
test "perform/1 processes a valid application and updates the summary" do
  application = insert(:application, resume_text: "Sample resume text")
  
  assert :ok = CVSummarizationWorker.perform(%Oban.Job{args: %{"application_id" => application.id}})
  
  updated = Applications.get_application!(application.id)
  assert updated.summary_status == "completed"
  assert updated.cv_summary != nil
end
```

## Future Enhancements

Potential improvements to the CV summarization feature:

1. **Keyword Extraction**: Identify and highlight key skills and qualifications
2. **Customizable Summaries**: Allow admins to specify focus areas for summarization
3. **Batch Processing**: Enable summarization of multiple CVs at once
4. **Summary Comparisons**: Compare summaries across multiple candidates
5. **Integration with Job Requirements**: Highlight aspects of the CV that match job requirements
