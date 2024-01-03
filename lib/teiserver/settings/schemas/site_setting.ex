defmodule Teiserver.Settings.ServerSetting do
  @moduledoc """
  # Site setting
  A key/value storage of settings used as part of the server.

  ### Attributes

  * `:key` - The key of the setting
  * `:email` - The value of the setting
  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "settings_server" do
    field(:key, :string, primary_key: true)
    field(:value, :string)

    timestamps()
  end

  @type t :: %__MODULE__{
    key: String.t(),
    value: String.t(),

    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil
  }

  @doc false
  def changeset(server_setting, attrs \\ %{}) do
    server_setting
    |> cast(attrs, ~w(key value)a)
    |> validate_required(~w(key value)a)
  end
end
