defmodule RecruitmentWeb.Admin.ApplicationShowLive do
  use RecruitmentWeb, :live_view
  
  alias Recruitment.Applications
  alias Recruitment.Jobs
  alias Phoenix.PubSub
  alias RecruitmentWeb.Live.Components.CvSummaryComponent
  
  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      # Subscribe to updates for this application
      PubSub.subscribe(Recruitment.PubSub, "application:#{id}")
    end
    
    application = Applications.get_application!(id)
    
    {:ok, 
     socket
     |> assign(:page_title, "Application Details")
     |> assign(:application, application)}
  end
  
  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    application = Applications.get_application!(id)
    job = Jobs.get_job!(application.job_id)
    
    {:noreply,
     socket
     |> assign(:application, application)
     |> assign(:job, job)}
  end
  
  @impl true
  def handle_info({:cv_summary_updated, updated_application}, socket) do
    # Update the application in the socket when we receive a PubSub message
    {:noreply, assign(socket, :application, updated_application)}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-gray-900">Application Details</h1>
        <.link
          navigate={~p"/admin/applications"}
          class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Back to Applications
        </.link>
      </div>
      
      <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <div class="px-4 py-5 sm:px-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900">Applicant Information</h3>
          <p class="mt-1 max-w-2xl text-sm text-gray-500">Personal details and application status.</p>
        </div>
        <div class="border-t border-gray-200 px-4 py-5 sm:p-0">
          <dl class="sm:divide-y sm:divide-gray-200">
            <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Full name</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                <%= @application.first_name %> <%= @application.last_name %>
              </dd>
            </div>
            <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Email address</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2"><%= @application.email %></dd>
            </div>
            <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Phone number</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2"><%= @application.phone %></dd>
            </div>
            <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Applied for</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                <.link navigate={~p"/admin/jobs/#{@job.id}"} class="text-indigo-600 hover:text-indigo-900">
                  <%= @job.title %> (<%= @job.location %>)
                </.link>
              </dd>
            </div>
            <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Application status</dt>
              <dd class="mt-1 text-sm sm:mt-0 sm:col-span-2">
                <span class={"px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_color(@application.status)}"}>
                  <%= @application.status %>
                </span>
              </dd>
            </div>
            <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Resume</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                <%= if @application.resume do %>
                  <.link href="#" class="text-indigo-600 hover:text-indigo-900">
                    Download Resume
                  </.link>
                <% else %>
                  <span class="text-gray-500">No resume uploaded</span>
                <% end %>
              </dd>
            </div>
            <div class="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
              <dt class="text-sm font-medium text-gray-500">Cover Letter</dt>
              <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                <%= if @application.cover_letter do %>
                  <div class="prose max-w-none">
                    <p><%= @application.cover_letter %></p>
                  </div>
                <% else %>
                  <span class="text-gray-500">No cover letter provided</span>
                <% end %>
              </dd>
            </div>
          </dl>
        </div>
      </div>
      
      <!-- CV Summary Component -->
      <.live_component
        module={CvSummaryComponent}
        id={"cv-summary-#{@application.id}"}
        application={@application}
      />
      
      <div class="mt-6 flex justify-end">
        <div class="flex space-x-3">
          <button
            type="button"
            class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Reject
          </button>
          <button
            type="button"
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Move to Interview
          </button>
        </div>
      </div>
    </div>
    """
  end
  
  # Helper function to determine status color
  defp status_color(status) do
    case status do
      "submitted" -> "bg-blue-100 text-blue-800"
      "reviewed" -> "bg-yellow-100 text-yellow-800"
      "interviewed" -> "bg-purple-100 text-purple-800"
      "rejected" -> "bg-red-100 text-red-800"
      "hired" -> "bg-green-100 text-green-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end
end
