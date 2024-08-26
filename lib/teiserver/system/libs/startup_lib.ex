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
      description:
        "The upper bound on how many failed attempts a given IP can perform before all further attempts will be blocked"
    })

    Settings.add_server_setting_type(%{
      key: "login.user_rate_limit",
      label: "Login rate limit per User",
      section: "Login",
      type: "integer",
      permissions: "Admin",
      default: nil,
      description:
        "The upper bound on how many failed attempts a given user can have before their logins are blocked."
    })

    Settings.add_user_setting_type(%{
      key: "language",
      label: "Language",
      section: "interface",
      type: "string",
      permissions: nil,
      choices: ["English", "American", "Spanish", "Lojban", "Bork bork"],
      default: "English",
      description: "The language used in the interface"
    })

    Settings.add_user_setting_type(%{
      key: "timezone",
      label: "Timezone",
      section: "interface",
      type: "integer",
      permissions: nil,
      default: 0,
      description: "The timezone to convert all Times to.",
      validator: fn v ->
        if -12 <= v and v <= 14,
          do: :ok,
          else: {:error, "Timezone must be within -12 and +14 hours of UTC"}
      end
    })
  end
end
