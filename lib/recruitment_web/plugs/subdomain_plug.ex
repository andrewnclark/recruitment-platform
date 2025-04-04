defmodule RecruitmentWeb.Plugs.SubdomainPlug do
  @moduledoc """
  A plug that extracts subdomain information from the request and assigns it to the connection.
  This allows for routing based on subdomains.
  """
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    host = conn.host || ""
    parts = String.split(host, ".")

    subdomain =
      case parts do
        [_, "localhost"] -> nil
        [sub, "localhost"] -> sub
        [sub | _] -> sub
        _ -> nil
      end

    assign(conn, :subdomain, subdomain)
  end

  defp get_subdomain(host) do
    root_domain = Application.get_env(:recruitment, :root_domain, "localhost")

    case String.split(host, ".") do
      [subdomain, ^root_domain] -> subdomain
      [subdomain, _rest, ^root_domain] -> subdomain
      [subdomain, _rest1, _rest2, ^root_domain] -> subdomain
      ["localhost"] -> nil
      [_] -> nil
      _ ->
        # For development with localhost:4000
        if String.contains?(host, "localhost"), do: nil, else: nil
    end
  end
end
