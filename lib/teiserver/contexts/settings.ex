defmodule Teiserver.Settings do
  @moduledoc """
  The contextual module for [SiteSetting](Teiserver.Settings.SiteSetting), [UserSetting](Teiserver.Settings.UserSetting)
  """

  alias Teiserver.Settings.{SiteSetting, SiteSettingLib}

  @doc section: :site_setting
  @spec list_site_settings() :: [SiteSetting.t()]
  defdelegate list_site_settings(), to: SiteSettingLib

  @doc section: :site_setting
  @spec list_site_settings(list) :: [SiteSetting.t()]
  defdelegate list_site_settings(args), to: SiteSettingLib

  @doc section: :site_setting
  @spec get_site_setting!(non_neg_integer(), list) :: SiteSetting.t()
  defdelegate get_site_setting!(site_setting_id, query_args \\ []), to: SiteSettingLib

  @doc section: :site_setting
  @spec get_site_setting(non_neg_integer(), list) :: SiteSetting.t() | nil
  defdelegate get_site_setting(site_setting_id, query_args \\ []), to: SiteSettingLib

  @doc section: :site_setting
  @spec create_site_setting(map) :: {:ok, SiteSetting.t()} | {:error, Ecto.Changeset}
  defdelegate create_site_setting(attrs \\ %{}), to: SiteSettingLib

  @doc section: :site_setting
  @spec update_site_setting(SiteSetting, map) :: {:ok, SiteSetting.t()} | {:error, Ecto.Changeset}
  defdelegate update_site_setting(site_setting, attrs), to: SiteSettingLib

  @doc section: :site_setting
  @spec delete_site_setting(SiteSetting.t()) :: {:ok, SiteSetting.t()} | {:error, Ecto.Changeset}
  defdelegate delete_site_setting(site_setting), to: SiteSettingLib

  @doc section: :site_setting
  @spec change_site_setting(SiteSetting.t(), map) :: Ecto.Changeset
  defdelegate change_site_setting(site_setting, attrs \\ %{}), to: SiteSettingLib

  alias Teiserver.Settings.{UserSetting, UserSettingLib}

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
  @spec change_user_setting(UserSetting.t(), map) :: Ecto.Changeset
  defdelegate change_user_setting(user_setting, attrs \\ %{}), to: UserSettingLib
end
