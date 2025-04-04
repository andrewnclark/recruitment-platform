defmodule RecruitmentWeb.Plugs.HostSubdomainPlug do
  @moduledoc """
  A plug that extracts subdomain information from the request host.
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
end
