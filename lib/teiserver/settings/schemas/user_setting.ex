defmodule Teiserver.Settings.UserSetting do
  @moduledoc false
  use TeiserverMacros, :schema

  schema "settings_user" do
    belongs_to(:user, Teiserver.Account.User)
    field(:key, :string)
    field(:value, :string)

    timestamps()
  end

  @doc false
  def changeset(site_setting, attrs \\ %{}) do
    site_setting
    |> cast(attrs, ~w(user_id key value)a)
    |> validate_required(~w(user_id key value)a)
  end
end
