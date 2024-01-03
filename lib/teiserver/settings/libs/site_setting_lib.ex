defmodule Teiserver.Settings.ServerSettingLib do
  @moduledoc """
  Library of server_setting related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Settings.{ServerSetting, ServerSettingQueries}

  @doc """
  Returns the list of server_settings.

  ## Examples

      iex> list_server_settings()
      [%ServerSetting{}, ...]

  """
  @spec list_server_settings(list) :: list
  def list_server_settings(query_args \\ []) do
    query_args
    |> ServerSettingQueries.query_server_settings()
    |> Teiserver.repo.all()
  end

  @doc """
  Gets a single server_setting.

  Raises `Ecto.NoResultsError` if the ServerSetting does not exist.

  ## Examples

      iex> get_server_setting!(123)
      %ServerSetting{}

      iex> get_server_setting!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_server_setting!(non_neg_integer()) :: ServerSetting.t()
  def get_server_setting!(server_setting_id, query_args \\ []) do
    (query_args ++ [id: server_setting_id])
    |> ServerSettingQueries.query_server_settings()
    |> Teiserver.repo.one!()
  end

  @doc """
  Gets a single server_setting.

  Returns nil if the ServerSetting does not exist.

  ## Examples

      iex> get_server_setting(123)
      %ServerSetting{}

      iex> get_server_setting(456)
      nil

  """
  @spec get_server_setting(non_neg_integer(), list) :: ServerSetting.t() | nil
  def get_server_setting(server_setting_id, query_args \\ []) do
    (query_args ++ [id: server_setting_id])
    |> ServerSettingQueries.query_server_settings()
    |> Teiserver.repo.one()
  end

  @doc """
  Creates a server_setting.

  ## Examples

      iex> create_server_setting(%{field: value})
      {:ok, %ServerSetting{}}

      iex> create_server_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_server_setting(map) :: {:ok, ServerSetting.t()} | {:error, Ecto.Changeset.t()}
  def create_server_setting(attrs \\ %{}) do
    %ServerSetting{}
    |> ServerSetting.changeset(attrs)
    |> Teiserver.repo.insert()
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
    |> Teiserver.repo.update()
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
    Teiserver.repo.delete(server_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_setting changes.

  ## Examples

      iex> change_server_setting(server_setting)
      %Ecto.Changeset{data: %ServerSetting{}}

  """
  @spec change_server_setting(ServerSetting.t(), map) :: Ecto.Changeset
  def change_server_setting(%ServerSetting{} = server_setting, attrs \\ %{}) do
    ServerSetting.changeset(server_setting, attrs)
  end
end
