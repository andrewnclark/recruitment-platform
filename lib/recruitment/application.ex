defmodule Recruitment.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RecruitmentWeb.Telemetry,
      Recruitment.Repo,
      {DNSCluster, query: Application.get_env(:recruitment, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Recruitment.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Recruitment.Finch},
      # Start Oban for background job processing
      {Oban, Application.fetch_env!(:recruitment, Oban)},
      # Start a worker by calling: Recruitment.Worker.start_link(arg)
      # {Recruitment.Worker, arg},
      # Start to serve requests, typically the last entry
      RecruitmentWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Recruitment.Supervisor]
    
    # Initialize the CV summarization service
    _ = Task.async(fn -> Recruitment.AI.CVSummarizer.init() end)
    
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RecruitmentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
