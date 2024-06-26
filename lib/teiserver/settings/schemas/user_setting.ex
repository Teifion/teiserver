defmodule Teiserver.Settings.UserSetting do
  @moduledoc """
  # User setting
  A key/value storage of settings tied to users. They are backed by the database but cached so can be accessed easily. Each user has their own settings with types defined by `Teiserver.Settings.UserSettingType`.

  The intended use case for User settings is anything where you want to store a key-value store against the user.

  ### Attributes

  * `:user_id` - A reference to the User in question
  * `:key` - The key of the setting linking it to a `Teiserver.Settings.UserSettingType`
  * `:value` - The value of the setting
  """
  use TeiserverMacros, :schema

  schema "settings_user_settings" do
    belongs_to(:user, Teiserver.Account.User, type: Ecto.UUID)
    field(:key, :string)
    field(:value, :string)

    timestamps(type: :utc_datetime)
  end

  @type key :: String.t()

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          user_id: Teiserver.user_id(),
          key: String.t(),
          value: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(server_setting, attrs \\ %{}) do
    server_setting
    |> cast(attrs, ~w(user_id key value)a)
    |> validate_required(~w(user_id key value)a)
  end
end
