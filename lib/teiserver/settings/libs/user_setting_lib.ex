defmodule Teiserver.Settings.UserSettingLib do
  @moduledoc """
  Library of user_setting related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Settings.{UserSetting, UserSettingQueries}

  @doc """
  Returns the list of user_settings.

  ## Examples

      iex> list_user_settings()
      [%UserSetting{}, ...]

  """
  @spec list_user_settings(list) :: list
  def list_user_settings(query_args \\ []) do
    conf = Teiserver.config()
    query = UserSettingQueries.query_user_settings(query_args)
    Repo.all(conf, query)
  end

  @doc """
  Gets a single user_setting.

  Raises `Ecto.NoResultsError` if the UserSetting does not exist.

  ## Examples

      iex> get_user_setting!(123)
      %UserSetting{}

      iex> get_user_setting!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_setting!(non_neg_integer()) :: UserSetting.t()
  def get_user_setting!(user_setting_id, query_args \\ []) do
    conf = Teiserver.config()
    query = UserSettingQueries.query_user_settings(query_args ++ [id: user_setting_id])
    Repo.one!(conf, query)
  end

  @doc """
  Gets a single user_setting.

  Returns nil if the UserSetting does not exist.

  ## Examples

      iex> get_user_setting(123)
      %UserSetting{}

      iex> get_user_setting(456)
      nil

  """
  @spec get_user_setting(non_neg_integer(), list) :: UserSetting.t() | nil
  def get_user_setting(user_setting_id, query_args \\ []) do
    conf = Teiserver.config()
    query = UserSettingQueries.query_user_settings(query_args ++ [id: user_setting_id])
    Repo.one(conf, query)
  end

  @doc """
  Creates a user_setting.

  ## Examples

      iex> create_user_setting(%{field: value})
      {:ok, %UserSetting{}}

      iex> create_user_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user_setting(map) :: {:ok, UserSetting.t()} | {:error, Ecto.Changeset}
  def create_user_setting(attrs \\ %{}) do
    conf = Teiserver.config()
    changeset = UserSetting.changeset(%UserSetting{}, attrs)
    Repo.insert(conf, changeset)
  end

  @doc """
  Updates a user_setting.

  ## Examples

      iex> update_user_setting(user_setting, %{field: new_value})
      {:ok, %UserSetting{}}

      iex> update_user_setting(user_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user_setting(UserSetting, map) :: {:ok, UserSetting.t()} | {:error, Ecto.Changeset}
  def update_user_setting(%UserSetting{} = user_setting, attrs) do
    conf = Teiserver.config()
    changeset = UserSetting.changeset(user_setting, attrs)
    Repo.update(conf, changeset)
  end

  @doc """
  Deletes a user_setting.

  ## Examples

      iex> delete_user_setting(user_setting)
      {:ok, %UserSetting{}}

      iex> delete_user_setting(user_setting)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user_setting(UserSetting.t()) :: {:ok, UserSetting.t()} | {:error, Ecto.Changeset}
  def delete_user_setting(%UserSetting{} = user_setting) do
    conf = Teiserver.config()
    Repo.delete(conf, user_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_setting changes.

  ## Examples

      iex> change_user_setting(user_setting)
      %Ecto.Changeset{data: %UserSetting{}}

  """
  @spec change_user_setting(UserSetting.t(), map) :: Ecto.Changeset
  def change_user_setting(%UserSetting{} = user_setting, attrs \\ %{}) do
    UserSetting.changeset(user_setting, attrs)
  end
end
