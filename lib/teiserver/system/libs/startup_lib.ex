defmodule Teiserver.System.StartupLib do
  @moduledoc false
  # Functionality executed during the Teisever startup process.

  alias Teiserver.Settings

  @spec perform() :: any()
  def perform do
    Settings.add_server_setting_type(%{
      key: "login.ip_rate_limit",
      label: "Login rate limit per IP",
      section: "Login",
      type: "integer",
      permissions: "Admin",
      default: 3,
      description: "The upper bound on how many failed attempts a given IP can perform before all further attempts will be blocked"
    })

    Settings.add_server_setting_type(%{
      key: "login.user_rate_limit",
      label: "Login rate limit per User",
      section: "Login",
      type: "integer",
      permissions: "Admin",
      default: nil,
      description: "The upper bound on how many failed attempts a given user can have before their logins are blocked."
    })
  end
end
