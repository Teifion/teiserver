defmodule Teiserver.Settings.ServerSettingTypeLib do
  @moduledoc """
  A library of functions for working with `Teiserver.Settings.ServerSettingType`
  """

  @cache_table :ts_server_setting_type_store

  alias Teiserver.Settings.ServerSettingType

  @spec list_server_setting_types([String.t()]) :: [ServerSettingType.t()]
  def list_server_setting_types(keys) do
    keys
    |> Enum.map(&get_server_setting_type/1)
  end

  @spec list_server_setting_type_keys() :: [String.t()]
  def list_server_setting_type_keys() do
    {:ok, v} = Cachex.get(@cache_table, "_all")
    v || []
  end

  @spec get_server_setting_type(String.t()) :: ServerSettingType.t() | nil
  def get_server_setting_type(key) do
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

  ## Examples
  ```
  add_server_setting_type(%{
    key: "login.ip_rate_limit",
    label: "Login rate limit per IP",
    section: "Login",
    type: "integer",
    permissions: "Admin",
    default: 3,
    description: "The upper bound on how many failed attempts a given IP can perform before all further attempts will be blocked"
  })
  ```
  """
  @spec add_server_setting_type(map()) :: {:ok, ServerSettingType.t()} | {:error, String.t()}
  def add_server_setting_type(args) do
    if not Enum.member?(~w(string integer boolean), args.type) do
      raise "Invalid type of '#{args.type}', must be one of 'string', 'integer' or 'boolean'"
    end

    existing_keys = list_server_setting_type_keys()

    if Enum.member?(existing_keys, args.key) do
      raise "Key #{args.key} already exists"
    end

    type = %ServerSettingType{
      key: args.key,
      label: args.label,
      section: args.section,
      type: args.type,
      permissions: Map.get(args, :permissions),
      choices: Map.get(args, :choices),
      default: Map.get(args, :default),
      description: Map.get(args, :description)
    }

    # Update our list of all keys
    new_all = [type.key | existing_keys]
    Cachex.put(@cache_table, "_all", new_all)

    Cachex.put(@cache_table, type.key, type)
    {:ok, type}
  end
end
