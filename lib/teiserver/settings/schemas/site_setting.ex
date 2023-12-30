defmodule Teiserver.Settings.SiteSetting do
  @moduledoc false
  use TeiserverMacros, :schema

  @primary_key false
  schema "settings_site" do
    field(:key, :string, primary_key: true)
    field(:value, :string)

    timestamps()
  end

  @doc false
  def changeset(site_setting, attrs \\ %{}) do
    site_setting
    |> cast(attrs, ~w(key value)a)
    |> validate_required(~w(key value)a)
  end
end
