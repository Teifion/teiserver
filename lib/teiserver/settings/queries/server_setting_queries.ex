defmodule Teiserver.Settings.ServerSettingQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Settings.ServerSetting
  require Logger

  @spec server_setting_query(Teiserver.query_args()) :: Ecto.Query.t()
  def server_setting_query(args) do
    query = from(server_settings in ServerSetting)

    query
    |> do_where(key: args[:key])
    |> do_where(args[:where])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), atom, any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :key, key_list) when is_list(key_list) do
    from(server_settings in query,
      where: server_settings.key in ^key_list
    )
  end

  def _where(query, :key, key) do
    from(server_settings in query,
      where: server_settings.key == ^key
    )
  end

  def _where(query, :value, value_list) when is_list(value_list) do
    from(server_settings in query,
      where: server_settings.value in ^value_list
    )
  end

  def _where(query, :value, value) do
    from(server_settings in query,
      where: server_settings.value == ^value
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(server_settings in query,
      where: server_settings.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(server_settings in query,
      where: server_settings.inserted_at < ^timestamp
    )
  end

  def _where(query, :updated_after, timestamp) do
    from(server_settings in query,
      where: server_settings.updated_at >= ^timestamp
    )
  end

  def _where(query, :updated_before, timestamp) do
    from(server_settings in query,
      where: server_settings.updated_at < ^timestamp
    )
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Newest first") do
    from(server_settings in query,
      order_by: [desc: server_settings.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(server_settings in query,
      order_by: [asc: server_settings.inserted_at]
    )
  end
end
