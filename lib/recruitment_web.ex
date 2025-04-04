defmodule RecruitmentWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use RecruitmentWeb, :controller
      use RecruitmentWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: {RecruitmentWeb.Layouts, :app}]

      use Gettext, backend: RecruitmentWeb.Gettext

      unquote(verified_routes())
    end
  end

  def admin_controller(_opts) do
    quote do
      use Phoenix.Controller,
        namespace: RecruitmentWeb.Admin,
        formats: [:html, :json],
        layouts: [html: {RecruitmentWeb.Layouts, :admin}]

      import Plug.Conn
      import RecruitmentWeb.Gettext

      unquote(verified_routes())
    end
  end

  def apply_controller(_opts) do
    quote do
      use Phoenix.Controller,
        namespace: RecruitmentWeb.Apply,
        formats: [:html, :json],
        layouts: [html: {RecruitmentWeb.Layouts, :apply}]

      import Plug.Conn
      import RecruitmentWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {RecruitmentWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def admin_live_view(_opts) do
    quote do
      use Phoenix.LiveView,
        layout: {RecruitmentWeb.Layouts, :admin}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: RecruitmentWeb.Gettext

      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import RecruitmentWeb.CoreComponents
      import RecruitmentWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: RecruitmentWeb.Endpoint,
        router: RecruitmentWeb.Router,
        statics: RecruitmentWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  # Special case for admin_controller and apply_controller
  defmacro __using__({which, opts}) when is_atom(which) do
    apply(__MODULE__, which, [opts])
  end
end
