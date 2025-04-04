defmodule RecruitmentWeb.Live.Components.CvSummaryComponent do
  use RecruitmentWeb, :live_component
  
  alias Recruitment.Applications
  alias Phoenix.PubSub
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="cv-summary-container">
      <div class="cv-summary-header flex justify-between items-center mb-4">
        <%= if @summary_status == "pending" do %>
          <button phx-click="request_summary" phx-target={@myself} class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            Generate Summary
          </button>
        <% end %>
      </div>
      
      <div class="cv-summary-content">
        <%= case @summary_status do %>
          <% "pending" -> %>
            <div class="cv-summary-placeholder bg-gray-50 p-4 rounded border border-gray-200">
              <p class="text-gray-600">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block mr-1" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
                </svg>
                Click "Generate Summary" to analyze this CV with AI.
              </p>
            </div>
            
          <% "processing" -> %>
            <div class="cv-summary-processing bg-blue-50 p-4 rounded border border-blue-200">
              <div class="flex items-center">
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <p class="text-blue-700">Analyzing CV... This may take a moment.</p>
              </div>
            </div>
            
          <% "completed" -> %>
            <div class="cv-summary-result prose max-w-none">
              <%= raw Earmark.as_html!(@cv_summary) %>
            </div>
            
          <% "error" -> %>
            <div class="cv-summary-error bg-red-50 p-4 rounded border border-red-200">
              <p class="text-red-700 mb-2">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block mr-1" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                </svg>
                There was an error processing this CV.
              </p>
              <button phx-click="retry_summary" phx-target={@myself} class="inline-flex items-center px-3 py-1.5 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                Retry
              </button>
            </div>
        <% end %>
      </div>
    </div>
    """
  end
  
  @impl true
  def mount(socket) do
    {:ok, socket}
  end
  
  @impl true
  def update(%{application: application} = assigns, socket) do
    if connected?(socket) do
      PubSub.subscribe(Recruitment.PubSub, "application:#{application.id}:summary")
    end
    
    {:ok, 
     socket
     |> assign(assigns)
     |> assign(:summary_status, application.summary_status || "pending")
     |> assign(:cv_summary, application.cv_summary)}
  end
  
  @impl true
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
  
  @impl true
  def handle_event("retry_summary", _params, socket) do
    # Reset status and try again
    Applications.update_application(socket.assigns.application, %{summary_status: "pending"})
    
    {:noreply, 
     socket
     |> assign(:summary_status, "pending")
     |> assign(:cv_summary, nil)}
  end
  
  @impl true
  def handle_info({:cv_summary_updated, updated_application}, socket) do
    {:noreply, 
     socket
     |> assign(:summary_status, updated_application.summary_status)
     |> assign(:cv_summary, updated_application.cv_summary)}
  end
end
