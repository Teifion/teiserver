defmodule Teiserver.Settings.ServerSettingLib do
  @moduledoc """
  A library of functions for working with `Teiserver.Settings.ServerSetting`
  """
  use TeiserverMacros, :library
  alias Teiserver.Settings.{ServerSetting, ServerSettingQueries, ServerSettingTypeLib}

  @doc """
  Returns the list of server_settings.

  ## Examples

      iex> list_server_settings()
      [%ServerSetting{}, ...]

  """
  @spec list_server_settings(Teiserver.query_args()) :: [ServerSetting.t()]
  def list_server_settings(query_args) do
    query_args
    |> ServerSettingQueries.server_setting_query()
    |> Repo.all()
  end

  @doc """
  Gets a single server_setting.

  Raises `Ecto.NoResultsError` if the ServerSetting does not exist.

  ## Examples

      iex> get_server_setting!("key123")
      %ServerSetting{}

      iex> get_server_setting!("key456")
      ** (Ecto.NoResultsError)

  """
  @spec get_server_setting!(ServerSetting.key()) :: ServerSetting.t()
  @spec get_server_setting!(ServerSetting.key(), Teiserver.query_args()) :: ServerSetting.t()
  def get_server_setting!(key, query_args \\ []) do
    (query_args ++ [key: key])
    |> ServerSettingQueries.server_setting_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single server_setting.

  Returns nil if the ServerSetting does not exist.

  ## Examples

      iex> get_server_setting("key123")
      %ServerSetting{}

      iex> get_server_setting("key456")
      nil

  """
  @spec get_server_setting(ServerSetting.key()) :: ServerSetting.t() | nil
  @spec get_server_setting(ServerSetting.key(), Teiserver.query_args()) :: ServerSetting.t() | nil
  def get_server_setting(key, query_args \\ []) do
    (query_args ++ [key: key])
    |> ServerSettingQueries.server_setting_query()
    |> Repo.one()
  end

  @doc """
  Gets the value of a server_setting.

  Returns nil if the ServerSetting does not exist.

  ## Examples

      iex> get_server_setting_value("key123")
      "value"

      iex> get_server_setting_value("key456")
      nil

  """
  @spec get_server_setting_value(ServerSetting.key()) ::
          String.t() | non_neg_integer() | boolean() | nil
  def get_server_setting_value(key) do
    case Cachex.get(:ts_server_setting_cache, key) do
      {:ok, nil} ->
        setting = get_server_setting(key, limit: 1)
        type = ServerSettingTypeLib.get_server_setting_type(key)

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

        Cachex.put(:ts_server_setting_cache, key, value)
        value

      {:ok, value} ->
        value
    end
  end

  @spec convert_from_raw_value(String.t(), String.t()) :: String.t() | integer() | boolean() | nil
  defp convert_from_raw_value(nil, _), do: nil
  defp convert_from_raw_value(raw_value, "string"), do: raw_value
  defp convert_from_raw_value(raw_value, "integer") when is_integer(raw_value), do: raw_value
  defp convert_from_raw_value(raw_value, "integer"), do: String.to_integer(raw_value)
  defp convert_from_raw_value(true, "boolean"), do: true
  defp convert_from_raw_value(false, "boolean"), do: false
  defp convert_from_raw_value(raw_value, "boolean"), do: raw_value == "t"
  defp convert_from_raw_value(_, _), do: nil

  @spec set_server_setting_value(String.t(), String.t() | non_neg_integer() | boolean() | nil) ::
          :ok
  def set_server_setting_value(key, value) do
    type = ServerSettingTypeLib.get_server_setting_type(key)
    raw_value = convert_to_raw_value(value, type.type)

    case get_server_setting(key) do
      nil ->
        {:ok, _} =
          create_server_setting(%{
            key: key,
            value: raw_value
          })

        Teiserver.invalidate_cache(:ts_server_setting_cache, key)
        :ok

      server_setting ->
        {:ok, _} = update_server_setting(server_setting, %{"value" => raw_value})
        Teiserver.invalidate_cache(:ts_server_setting_cache, key)
        :ok
    end
  end

  @spec convert_to_raw_value(String.t(), String.t()) :: String.t() | integer() | boolean() | nil
  defp convert_to_raw_value(value, "string"), do: value
  defp convert_to_raw_value(value, "integer"), do: to_string(value)
  defp convert_to_raw_value(value, "boolean"), do: if(value, do: "t", else: "f")
  defp convert_to_raw_value(_, _), do: nil

  @doc """
  Creates a server_setting.

  ## Examples

      iex> create_server_setting(%{field: value})
      {:ok, %ServerSetting{}}

      iex> create_server_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_setting(map) :: {:ok, ServerSetting.t()} | {:error, Ecto.Changeset.t()}
  def create_server_setting(attrs) do
    %ServerSetting{}
    |> ServerSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_setting.

  ## Examples

      iex> update_server_setting(server_setting, %{field: new_value})
      {:ok, %ServerSetting{}}

      iex> update_server_setting(server_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_server_setting(ServerSetting.t(), map) ::
          {:ok, ServerSetting.t()} | {:error, Ecto.Changeset.t()}
  def update_server_setting(%ServerSetting{} = server_setting, attrs) do
    server_setting
    |> ServerSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_setting.

  ## Examples

      iex> delete_server_setting(server_setting)
      {:ok, %ServerSetting{}}

      iex> delete_server_setting(server_setting)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_server_setting(ServerSetting.t()) ::
          {:ok, ServerSetting.t()} | {:error, Ecto.Changeset.t()}
  def delete_server_setting(%ServerSetting{} = server_setting) do
    Repo.delete(server_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_setting changes.

  ## Examples

      iex> change_server_setting(server_setting)
      %Ecto.Changeset{data: %ServerSetting{}}

  """
  @spec change_server_setting(ServerSetting.t(), map) :: Ecto.Changeset.t()
  def change_server_setting(%ServerSetting{} = server_setting, attrs \\ %{}) do
    ServerSetting.changeset(server_setting, attrs)
  end
end
