defmodule Teiserver.Settings do
  @moduledoc """
  The contextual module for:
  - `Teiserver.Settings.ServerSetting`
  - `Teiserver.Settings.UserSetting`
  """

  # ServerSettings
  alias Teiserver.Settings.{ServerSetting, ServerSettingLib, ServerSettingQueries}

  @doc false
  @spec server_setting_query(list) :: Ecto.Query.t()
  defdelegate server_setting_query(args), to: ServerSettingQueries

  @doc section: :server_setting
  @spec list_server_settings() :: [ServerSetting.t()]
  defdelegate list_server_settings(), to: ServerSettingLib

  @doc section: :server_setting
  @spec list_server_settings(list) :: [ServerSetting.t()]
  defdelegate list_server_settings(args), to: ServerSettingLib

  @doc section: :server_setting
  @spec get_server_setting!(non_neg_integer(), list) :: ServerSetting.t()
  defdelegate get_server_setting!(server_setting_id, query_args \\ []), to: ServerSettingLib

  @doc section: :server_setting
  @spec get_server_setting(non_neg_integer(), list) :: ServerSetting.t() | nil
  defdelegate get_server_setting(server_setting_id, query_args \\ []), to: ServerSettingLib

  @doc section: :server_setting
  @spec create_server_setting(map) :: {:ok, ServerSetting.t()} | {:error, Ecto.Changeset}
  defdelegate create_server_setting(attrs \\ %{}), to: ServerSettingLib

  @doc section: :server_setting
  @spec update_server_setting(ServerSetting, map) ::
          {:ok, ServerSetting.t()} | {:error, Ecto.Changeset}
  defdelegate update_server_setting(server_setting, attrs), to: ServerSettingLib

  @doc section: :server_setting
  @spec delete_server_setting(ServerSetting.t()) ::
          {:ok, ServerSetting.t()} | {:error, Ecto.Changeset}
  defdelegate delete_server_setting(server_setting), to: ServerSettingLib

  @doc section: :server_setting
  @spec change_server_setting(ServerSetting.t(), map) :: Ecto.Changeset
  defdelegate change_server_setting(server_setting, attrs \\ %{}), to: ServerSettingLib

  # UserSettings
  alias Teiserver.Settings.{UserSetting, UserSettingLib, UserSettingQueries}

  @doc false
  @spec user_setting_query(list) :: Ecto.Query.t()
  defdelegate user_setting_query(args), to: UserSettingQueries

  @doc section: :user_setting
  @spec list_user_settings() :: [UserSetting.t()]
  defdelegate list_user_settings(), to: UserSettingLib

  @doc section: :user_setting
  @spec list_user_settings(list) :: [UserSetting.t()]
  defdelegate list_user_settings(args), to: UserSettingLib

  @doc section: :user_setting
  @spec get_user_setting!(non_neg_integer(), list) :: UserSetting.t()
  defdelegate get_user_setting!(user_setting_id, query_args \\ []), to: UserSettingLib

  @doc section: :user_setting
  @spec get_user_setting(non_neg_integer(), list) :: UserSetting.t() | nil
  defdelegate get_user_setting(user_setting_id, query_args \\ []), to: UserSettingLib

  @doc section: :user_setting
  @spec create_user_setting(map) :: {:ok, UserSetting.t()} | {:error, Ecto.Changeset}
  defdelegate create_user_setting(attrs \\ %{}), to: UserSettingLib

  @doc section: :user_setting
  @spec update_user_setting(UserSetting, map) :: {:ok, UserSetting.t()} | {:error, Ecto.Changeset}
  defdelegate update_user_setting(user_setting, attrs), to: UserSettingLib

  @doc section: :user_setting
  @spec delete_user_setting(UserSetting.t()) :: {:ok, UserSetting.t()} | {:error, Ecto.Changeset}
  defdelegate delete_user_setting(user_setting), to: UserSettingLib

  @doc section: :user_setting
  @spec change_user_setting(UserSetting.t(), map) :: Ecto.Changeset.t()
  defdelegate change_user_setting(user_setting, attrs \\ %{}), to: UserSettingLib
end
