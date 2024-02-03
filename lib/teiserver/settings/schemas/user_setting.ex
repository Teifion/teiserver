defmodule Teiserver.Settings.UserSetting do
  @moduledoc """
  # User setting
  A key/value storage of settings tied to users

  ### Attributes

  * `:user_id` - A reference to the User in question
  * `:key` - The key of the setting
  * `:email` - The value of the setting
  """
  use TeiserverMacros, :schema

  schema "settings_user_settings" do
    belongs_to(:user, Teiserver.Account.User)
    field(:key, :string)
    field(:value, :string)

    timestamps()
  end

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          user_id: Teiserver.user_id(),
          key: String.t(),
          value: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(server_setting, attrs \\ %{}) do
    server_setting
    |> cast(attrs, ~w(user_id key value)a)
    |> validate_required(~w(user_id key value)a)
  end
end
