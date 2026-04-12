defmodule Teiserver.Settings do
  @moduledoc """
  The contextual module for:
  - `Teiserver.Settings.ServerSettingType`
  - `Teiserver.Settings.ServerSetting`
  - `Teiserver.Settings.UserSettingType`
  - `Teiserver.Settings.UserSetting`
  """

  # ServerSettingType
  alias Teiserver.Settings.{ServerSettingType, ServerSettingTypeLib}

  @doc section: :server_setting_type
  @spec list_server_setting_types([String.t()]) :: [ServerSettingType.t()]
  defdelegate list_server_setting_types(keys), to: ServerSettingTypeLib

  @doc section: :server_setting_type
  @spec list_server_setting_type_keys() :: [String.t()]
  defdelegate list_server_setting_type_keys(), to: ServerSettingTypeLib

  @doc section: :server_setting_type
  @spec get_server_setting_type(String.t()) :: ServerSettingType.t() | nil
  defdelegate get_server_setting_type(key), to: ServerSettingTypeLib

  @doc section: :server_setting_type
  @spec add_server_setting_type(map()) :: {:ok, ServerSettingType.t()} | {:error, String.t()}
  defdelegate add_server_setting_type(args), to: ServerSettingTypeLib

  # ServerSettings
  alias Teiserver.Settings.{ServerSetting, ServerSettingLib, ServerSettingQueries}

  @doc false
  @spec server_setting_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate server_setting_query(args), to: ServerSettingQueries

  @doc section: :server_setting
  @spec list_server_settings(Teiserver.query_args()) :: [ServerSetting.t()]
  defdelegate list_server_settings(args), to: ServerSettingLib

  @doc section: :server_setting
  @spec get_server_setting!(ServerSetting.key()) :: ServerSetting.t()
  @spec get_server_setting!(ServerSetting.key(), Teiserver.query_args()) :: ServerSetting.t()
  defdelegate get_server_setting!(server_setting_id, query_args \\ []), to: ServerSettingLib

  @doc section: :server_setting
  @spec get_server_setting(ServerSetting.key()) :: ServerSetting.t() | nil
  @spec get_server_setting(ServerSetting.key(), Teiserver.query_args()) :: ServerSetting.t() | nil
  defdelegate get_server_setting(server_setting_id, query_args \\ []), to: ServerSettingLib

  @doc section: :server_setting
  @spec create_server_setting(map) :: {:ok, ServerSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_server_setting(attrs), to: ServerSettingLib

  @doc section: :server_setting
  @spec update_server_setting(ServerSetting, map) ::
          {:ok, ServerSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_server_setting(server_setting, attrs), to: ServerSettingLib

  @doc section: :server_setting
  @spec delete_server_setting(ServerSetting.t()) ::
          {:ok, ServerSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_server_setting(server_setting), to: ServerSettingLib

  @doc section: :server_setting
  @spec change_server_setting(ServerSetting.t()) :: Ecto.Changeset.t()
  @spec change_server_setting(ServerSetting.t(), map) :: Ecto.Changeset.t()
  defdelegate change_server_setting(server_setting, attrs \\ %{}), to: ServerSettingLib

  @doc section: :server_setting
  @spec get_server_setting_value(String.t()) :: String.t() | integer() | boolean() | nil
  defdelegate get_server_setting_value(key), to: ServerSettingLib

  @doc section: :server_setting
  @spec set_server_setting_value(String.t(), String.t() | non_neg_integer() | boolean() | nil) ::
          :ok
  defdelegate set_server_setting_value(key, value), to: ServerSettingLib

  # UserSettingType
  alias Teiserver.Settings.{UserSettingType, UserSettingTypeLib}

  @doc section: :user_setting_type
  @spec list_user_setting_types([String.t()]) :: [UserSettingType.t()]
  defdelegate list_user_setting_types(keys), to: UserSettingTypeLib

  @doc section: :user_setting_type
  @spec list_user_setting_type_keys() :: [String.t()]
  defdelegate list_user_setting_type_keys(), to: UserSettingTypeLib

  @doc section: :user_setting_type
  @spec get_user_setting_type(String.t()) :: UserSettingType.t() | nil
  defdelegate get_user_setting_type(key), to: UserSettingTypeLib

  @doc section: :user_setting_type
  @spec add_user_setting_type(map()) :: {:ok, UserSettingType.t()} | {:error, String.t()}
  defdelegate add_user_setting_type(args), to: UserSettingTypeLib

  # UserSettings
  alias Teiserver.Settings.{UserSetting, UserSettingLib, UserSettingQueries}

  @doc false
  @spec user_setting_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate user_setting_query(args), to: UserSettingQueries

  @doc section: :user_setting
  @spec list_user_settings(Teiserver.query_args()) :: [UserSetting.t()]
  defdelegate list_user_settings(args), to: UserSettingLib

  @doc section: :user_setting
  @spec get_user_setting!(Teiserver.user_id(), UserSetting.key()) :: UserSetting.t()
  defdelegate get_user_setting!(user_id, key), to: UserSettingLib

  @doc section: :user_setting
  @spec get_user_setting(Teiserver.user_id(), UserSetting.key()) :: UserSetting.t() | nil
  defdelegate get_user_setting(user_id, key), to: UserSettingLib

  @doc section: :user_setting
  @spec create_user_setting(map) :: {:ok, UserSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_user_setting(attrs), to: UserSettingLib

  @doc section: :user_setting
  @spec update_user_setting(UserSetting.t(), map) ::
          {:ok, UserSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_user_setting(user_setting, attrs), to: UserSettingLib

  @doc section: :user_setting
  @spec delete_user_setting(UserSetting.t()) ::
          {:ok, UserSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_user_setting(user_setting), to: UserSettingLib

  @doc section: :user_setting
  @spec change_user_setting(UserSetting.t()) :: Ecto.Changeset.t()
  @spec change_user_setting(UserSetting.t(), map) :: Ecto.Changeset.t()
  defdelegate change_user_setting(user_setting, attrs \\ %{}), to: UserSettingLib

  @doc section: :user_setting
  @spec get_user_setting_value(Teiserver.user_id(), String.t()) ::
          String.t() | integer() | boolean() | nil
  defdelegate get_user_setting_value(user_id, key), to: UserSettingLib

  @doc section: :user_setting
  @spec set_user_setting_value(
          Teiserver.user_id(),
          String.t(),
          String.t() | non_neg_integer() | boolean() | nil
        ) :: :ok
  defdelegate set_user_setting_value(user_id, key, value), to: UserSettingLib
end
