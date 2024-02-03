defmodule Teiserver.Game.MatchSettingTypeQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Game.MatchSettingType
  require Logger

  @spec match_setting_type_query(Teiserver.query_args()) :: Ecto.Query.t()
  def match_setting_type_query(args) do
    query = from(match_setting_types in MatchSettingType)

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

  def _where(query, :id, id_list) when is_list(id_list) do
    from(match_setting_types in query,
      where: match_setting_types.id in ^id_list
    )
  end

  def _where(query, :id, id) do
    from(match_setting_types in query,
      where: match_setting_types.id == ^id
    )
  end

  def _where(query, :name, name) do
    from(match_setting_types in query,
      where: match_setting_types.name == ^name
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(match_setting_types in query,
      where: match_setting_types.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(match_setting_types in query,
      where: match_setting_types.inserted_at < ^timestamp
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

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Name (A-Z)") do
    from(match_setting_types in query,
      order_by: [asc: match_setting_types.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(match_setting_types in query,
      order_by: [desc: match_setting_types.name]
    )
  end

  def _order_by(query, "Newest first") do
    from(match_setting_types in query,
      order_by: [desc: match_setting_types.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(match_setting_types in query,
      order_by: [asc: match_setting_types.inserted_at]
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

  # @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  # def _preload(query, :relation) do
  #   from match_setting_type in query,
  #     left_join: relations in assoc(match_setting_type, :relation),
  #     preload: [relation: relations]
  # end

  # def _preload(query, {:relation, join_query}) do
  #   from match_setting_type in query,
  #     left_join: relations in subquery(join_query),
  #       on: relations.id == query.relation_id,
  #     preload: [relation: relations]
  # end
end
