defmodule Teiserver.Settings.UserSettingTypeLib do
  @moduledoc """
  A library of functions for working with `Teiserver.Settings.UserSettingType`
  """

  @cache_table :ts_user_setting_type_store

  alias Teiserver.Settings.UserSettingType

  @spec list_user_setting_types([String.t()]) :: [UserSettingType.t()]
  def list_user_setting_types(keys) do
    keys
    |> Enum.map(&get_user_setting_type/1)
    |> Enum.reject(&(&1 == nil))
  end

  @spec list_user_setting_type_keys() :: [String.t()]
  def list_user_setting_type_keys() do
    {:ok, v} = Cachex.get(@cache_table, "_all")
    v || []
  end

  @spec get_user_setting_type(String.t()) :: UserSettingType.t() | nil
  def get_user_setting_type(key) do
    {:ok, v} = Cachex.get(@cache_table, key)
    v
  end

  @doc """
  ### Required keys
  * `:key` - The string key of the setting, this is the internal name used for the setting
  * `:label` - The user-facing label used for the setting
  * `:section` - A string referencing how the setting should be grouped
  * `:type` - The type of value which should be parsed out, can be one of: `string`, `boolean`, `integer`

  ### Optional attributes
  * `:permissions` - A permission set (string or list of strings) used to check if a given user can edit this setting
  * `:choices` - A list of acceptable choices for `string` based types
  * `:default` - The default value for a setting if one is not set, defaults to `nil`
  * `:description` - A longer description which can be used to provide more information to users
  * `:validator` - A function taking a single value and returning `:ok | {:error, String.t()}` of if the value given is acceptable for the setting type

  ## Examples
  ```
  add_user_setting_type(%{
    key: "timezone",
    label: "Timezone",
    section: "interface",
    type: "integer",
    permissions: nil,
    default: 0,
    description: "The timezone to convert all Times to.",
    validator: (fn v -> if -12 <= v and v <= 14, do: :ok, else: {:error, "Timezone must be within -12 and +14 hours of UTC"} end)
  })
  ```
  """
  @spec add_user_setting_type(map()) :: {:ok, UserSettingType.t()} | {:error, String.t()}
  def add_user_setting_type(args) do
    if not Enum.member?(~w(string integer boolean), args.type) do
      raise "Invalid type, must be one of `string`, `integer` or `boolean`"
    end

    existing_keys = list_user_setting_type_keys()

    if Enum.member?(existing_keys, args.key) do
      raise "Key #{args.key} already exists"
    end

    type = %UserSettingType{
      key: args.key,
      label: args.label,
      section: args.section,
      type: args.type,
      permissions: Map.get(args, :permissions),
      choices: Map.get(args, :choices),
      default: Map.get(args, :default),
      description: Map.get(args, :description),
      validator: Map.get(args, :validator)
    }

    # Update our list of all keys
    new_all = [type.key | existing_keys]
    Cachex.put(@cache_table, "_all", new_all)

    Cachex.put(@cache_table, type.key, type)
    {:ok, type}
  end
end
