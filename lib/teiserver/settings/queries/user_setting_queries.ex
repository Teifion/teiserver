defmodule Teiserver.Settings.UserSettingQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Settings.UserSetting
  require Logger

  @spec query_user_settings(list) :: Ecto.Query.t()
  def query_user_settings(args) do
    query = from(user_settings in UserSetting)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_where(args[:search])
    |> do_preload(args[:preload])
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

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query
  def _where(query, _, "Any"), do: query

  def _where(query, :id, id) do
    from(user_settings in query,
      where: user_settings.id == ^id
    )
  end

  def _where(query, :id_in, id_list) do
    from(user_settings in query,
      where: user_settings.id in ^id_list
    )
  end

  def _where(query, :name, name) do
    from(user_settings in query,
      where: user_settings.name == ^name
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(user_settings in query,
      where: user_settings.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(user_settings in query,
      where: user_settings.inserted_at < ^timestamp
    )
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) when is_list(params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  def _order_by(query, "Name (A-Z)") do
    from(user_settings in query,
      order_by: [asc: user_settings.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(user_settings in query,
      order_by: [desc: user_settings.name]
    )
  end

  def _order_by(query, "Newest first") do
    from(user_settings in query,
      order_by: [desc: user_settings.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(user_settings in query,
      order_by: [asc: user_settings.inserted_at]
    )
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, _), do: query
  # defp do_preload(query, preloads) do
  #   preloads
  #   |> List.wrap
  #   |> Enum.reduce(query, fn key, query_acc ->
  #     _preload(query_acc, key)
  #   end)
  # end

  # def _preload(query, :relation) do
  #   from user_setting in query,
  #     left_join: relations in assoc(user_setting, :relation),
  #     preload: [relation: relations]
  # end
end
