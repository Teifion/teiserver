defmodule Teiserver.Settings.ServerSettingType do
  @moduledoc """
  # ServerSettingType
  A server setting type is a structure for server settings to reference. The setting types are created at node startup and though the values can be changed at runtime the types are not intended to be changed at runtime.

  ### Attributes

  * `:key` - The string key of the setting, this is the internal name used for the setting
  * `:label` - The user-facing label used for the setting
  * `:section` - A string referencing how the setting should be grouped
  * `:type` - The type of value which should be parsed out, can be one of: `string`, `boolean`, `integer`

  ### Optional attributes
  * `:permissions` - A permission set (string or list of strings) used to check if a given user can edit this setting
  * `:choices` - A list of acceptable choices for `string` based types
  * `:default` - The default value for a setting if one is not set, defaults to `nil`
  * `:description` - A longer description which can be used to provide more information to users
  * `:validator` - A function taking a single value and returning a `:ok | {:error, String.t()}` of if the value given is acceptable for the setting type
  """

  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    @typedoc "A server setting type"

    field(:key, Teiserver.Settings.ServerSetting.key())
    field(:label, String.t())
    field(:section, String.t())
    field(:type, String.t())

    field(:permissions, String.t() | [String.t()] | nil, default: nil)
    field(:choices, [String.t()] | nil, default: nil)
    field(:default, String.t() | integer() | boolean | nil, default: nil)
    field(:description, String.t() | nil, default: nil)
    field(:validator, function() | nil, default: nil)
  end
end
