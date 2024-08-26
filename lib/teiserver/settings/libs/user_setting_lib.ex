defmodule Teiserver.Settings.UserSettingLib do
  @moduledoc """
  A library of functions for working with `Teiserver.Settings.UserSetting`
  """
  use TeiserverMacros, :library
  alias Teiserver.Settings.{UserSetting, UserSettingQueries, UserSettingTypeLib}

  @doc """
  Returns the list of user_settings.

  ## Examples

      iex> list_user_settings()
      [%UserSetting{}, ...]

  """
  @spec list_user_settings(Teiserver.query_args()) :: [UserSetting.t()]
  def list_user_settings(query_args) do
    query_args
    |> UserSettingQueries.user_setting_query()
    |> Repo.all()
  end

  @doc """
  Gets a single user_setting.

  Raises `Ecto.NoResultsError` if the UserSetting does not exist.

  ## Examples

      iex> get_user_setting!("userid", "key123")
      %UserSetting{}

      iex> get_user_setting!("userid", "key456")
      ** (Ecto.NoResultsError)

  """
  @spec get_user_setting!(Teiserver.user_id(), UserSetting.key()) :: UserSetting.t()
  def get_user_setting!(user_id, key) do
    UserSettingQueries.user_setting_query(where: [key: key, user_id: user_id], limit: 1)
    |> Repo.one!()
  end

  @doc """
  Gets a single user_setting.

  Returns nil if the UserSetting does not exist.

  ## Examples

      iex> get_user_setting("userid", "key123")
      %UserSetting{}

      iex> get_user_setting("userid", "key456")
      nil

  """
  @spec get_user_setting(Teiserver.user_id(), UserSetting.key()) :: UserSetting.t() | nil
  def get_user_setting(user_id, key) do
    UserSettingQueries.user_setting_query(where: [key: key, user_id: user_id], limit: 1)
    |> Repo.one()
  end

  @doc """
  Gets the value of a user_setting.

  Returns nil if the UserSetting does not exist.

  ## Examples

      iex> get_user_setting_value("key123")
      "value"

      iex> get_user_setting_value("key456")
      nil

  """
  @spec get_user_setting_value(Teiserver.user_id(), String.t()) ::
          String.t() | integer() | boolean() | nil
  def get_user_setting_value(user_id, key) do
    lookup = cache_key(user_id, key)

    case Cachex.get(:ts_user_setting_cache, lookup) do
      {:ok, nil} ->
        setting = get_user_setting(user_id, key)
        type = UserSettingTypeLib.get_user_setting_type(key)

        value =
          case setting do
            nil ->
              type.default

            %{value: nil} ->
              type.default

            %{value: v} ->
              v
          end

        value = convert_from_raw_value(value, type.type)

        Cachex.put(:ts_user_setting_cache, lookup, value)
        value

      {:ok, value} ->
        value
    end
  end

  @spec convert_from_raw_value(String.t(), String.t()) :: String.t() | integer() | boolean() | nil
  defp convert_from_raw_value(raw_value, "string"), do: raw_value
  defp convert_from_raw_value(raw_value, "integer"), do: String.to_integer(raw_value)
  defp convert_from_raw_value(raw_value, "boolean"), do: raw_value == "t"
  defp convert_from_raw_value(_, _), do: nil

  @spec set_user_setting_value(
          Teiserver.user_id(),
          String.t(),
          String.t() | non_neg_integer() | boolean() | nil
        ) :: :ok
  def set_user_setting_value(user_id, key, value) do
    lookup = cache_key(user_id, key)

    type = UserSettingTypeLib.get_user_setting_type(key)
    raw_value = convert_to_raw_value(value, type.type)

    case value_is_valid?(type, value) do
      :ok ->
        case get_user_setting(user_id, key) do
          nil ->
            {:ok, _} =
              create_user_setting(%{
                user_id: user_id,
                key: key,
                value: raw_value
              })

            :ok

          user_setting ->
            {:ok, _} = update_user_setting(user_setting, %{"value" => raw_value})
            Teiserver.invalidate_cache(:ts_user_setting_cache, lookup)
            :ok
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """

  """
  @spec value_is_valid?(ServerSettingType.t(), String.t() | non_neg_integer() | boolean() | nil) ::
          :ok | {:error, String.t()}
  def value_is_valid?(%{validator: nil}, _), do: :ok

  def value_is_valid?(%{validator: validator_function}, value) do
    validator_function.(value)
  end

  @spec convert_to_raw_value(String.t(), String.t()) :: String.t() | integer() | boolean() | nil
  defp convert_to_raw_value(value, "string"), do: value
  defp convert_to_raw_value(value, "integer"), do: to_string(value)
  defp convert_to_raw_value(value, "boolean"), do: if(value, do: "t", else: "f")
  defp convert_to_raw_value(_, _), do: nil

  @doc """
  Creates a user_setting.

  ## Examples

      iex> create_user_setting(%{field: value})
      {:ok, %UserSetting{}}

      iex> create_user_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user_setting(map) :: {:ok, UserSetting.t()} | {:error, Ecto.Changeset.t()}
  def create_user_setting(attrs) do
    %UserSetting{}
    |> UserSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_setting.

  ## Examples

      iex> update_user_setting(user_setting, %{field: new_value})
      {:ok, %UserSetting{}}

      iex> update_user_setting(user_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user_setting(UserSetting.t(), map) ::
          {:ok, UserSetting.t()} | {:error, Ecto.Changeset.t()}
  def update_user_setting(%UserSetting{} = user_setting, attrs) do
    user_setting
    |> UserSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_setting.

  ## Examples

      iex> delete_user_setting(user_setting)
      {:ok, %UserSetting{}}

      iex> delete_user_setting(user_setting)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user_setting(UserSetting.t()) ::
          {:ok, UserSetting.t()} | {:error, Ecto.Changeset.t()}
  def delete_user_setting(%UserSetting{} = user_setting) do
    Repo.delete(user_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_setting changes.

  ## Examples

      iex> change_user_setting(user_setting)
      %Ecto.Changeset{data: %UserSetting{}}

  """
  @spec change_user_setting(UserSetting.t(), map) :: Ecto.Changeset.t()
  def change_user_setting(%UserSetting{} = user_setting, attrs \\ %{}) do
    UserSetting.changeset(user_setting, attrs)
  end

  defp cache_key(user_id, key) do
    "#{user_id}$#{key}"
  end
end
