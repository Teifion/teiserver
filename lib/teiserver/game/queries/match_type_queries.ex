defmodule Teiserver.Game.MatchTypeQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Game.MatchType
  require Logger

  @spec match_type_query(Teiserver.query_args()) :: Ecto.Query.t()
  def match_type_query(args) do
    query = from(match_types in MatchType)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
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

  @spec _where(Ecto.Query.t(), atom, any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id_list) when is_list(id_list) do
    from(match_types in query,
      where: match_types.id in ^id_list
    )
  end

  def _where(query, :id, id) do
    from(match_types in query,
      where: match_types.id == ^id
    )
  end

  def _where(query, :name, name_list) when is_list(name_list) do
    from(match_types in query,
      where: match_types.name in ^name_list
    )
  end

  def _where(query, :name, name) do
    from(match_types in query,
      where: match_types.name == ^name
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
    from(match_types in query,
      order_by: [asc: match_types.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(match_types in query,
      order_by: [desc: match_types.name]
    )
  end

  @spec do_preload(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
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
  #   from match_type in query,
  #     left_join: relations in assoc(match_type, :relation),
  #     preload: [relation: relations]
  # end
end
