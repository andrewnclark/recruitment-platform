defmodule RecruitmentWeb.Router do
  use RecruitmentWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RecruitmentWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Pipeline for the apply subdomain
  pipeline :apply_subdomain do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RecruitmentWeb.Layouts, :apply_root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  
  # Pipeline for the admin subdomain
  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RecruitmentWeb.Layouts, :admin_root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  
  # Pipeline for admin authentication
  pipeline :admin_auth do
    plug RecruitmentWeb.AdminAuthPlug
  end

  # Routes for the main domain
  scope "/", RecruitmentWeb do
    pipe_through :browser

    get "/", PageController, :home
    
    # Jobs routes
    get "/jobs", JobController, :index
    get "/jobs/:location/:slug", JobController, :show
  end

  # Routes for the "apply" subdomain
  scope "/", RecruitmentWeb.Apply, host: "apply." do
    pipe_through :apply_subdomain

    get "/", ApplicationController, :index
    get "/:location/:slug", ApplicationController, :new
    post "/:location/:slug", ApplicationController, :create
    get "/:location/:slug/success", ApplicationController, :success
  end
  
  # Admin routes
  scope "/", RecruitmentWeb.Admin, host: "admin.:domain" do
    pipe_through [:admin]

    get "/login", SessionController, :new
    post "/login", SessionController, :create
  end

  scope "/", RecruitmentWeb.Admin, host: "admin.:domain" do
    pipe_through [:admin, :admin_auth]

    get "/", DashboardController, :index
    delete "/logout", SessionController, :delete
    
    resources "/jobs", JobController
    resources "/applications", ApplicationController, except: [:new, :create, :edit]
    
    # LiveView route for application details with CV summary
    # live "/applications/:id/details", ApplicationShowLive, :show
    
    resources "/applicants", ApplicantController, except: [:new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", RecruitmentWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:recruitment, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RecruitmentWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
