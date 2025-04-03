defmodule RecruitmentWeb.SubdomainPlug do
  @moduledoc """
  A plug that extracts subdomain information from the request and assigns it to the connection.
  This allows for routing based on subdomains.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_subdomain(conn.host) do
      subdomain when subdomain in ["", nil] ->
        assign(conn, :subdomain, nil)
      subdomain ->
        assign(conn, :subdomain, subdomain)
    end
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
