defmodule Teiserver.Game.MatchQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Game.Match
  require Logger

  @spec match_query(Teiserver.query_args()) :: Ecto.Query.t()
  def match_query(args) do
    query = from(matches in Match)

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

  def _where(query, :id, id_list) do
    from(matches in query,
      where: matches.id in ^List.wrap(id_list)
    )
  end

  def _where(query, :name, name) do
    from(matches in query,
      where: matches.name == ^name
    )
  end

  def _where(query, :duration_gt, seconds) do
    from(matches in query,
      where: matches.match_duration_seconds > ^seconds
    )
  end

  def _where(query, :duration_lt, seconds) do
    from(matches in query,
      where: matches.match_duration_seconds < ^seconds
    )
  end

  def _where(query, :started_after, timestamp) do
    from(matches in query,
      where: matches.match_started_at >= ^timestamp
    )
  end

  def _where(query, :started_before, timestamp) do
    from(matches in query,
      where: matches.match_started_at < ^timestamp
    )
  end

  def _where(query, :ended_after, timestamp) do
    from(matches in query,
      where: matches.match_ended_at >= ^timestamp
    )
  end

  def _where(query, :ended_before, timestamp) do
    from(matches in query,
      where: matches.match_ended_at < ^timestamp
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(matches in query,
      where: matches.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(matches in query,
      where: matches.inserted_at < ^timestamp
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
  def _order_by(query, "Name (A-Z)") do
    from(matches in query,
      order_by: [asc: matches.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(matches in query,
      order_by: [desc: matches.name]
    )
  end

  def _order_by(query, "Newest first") do
    from(matches in query,
      order_by: [desc: matches.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(matches in query,
      order_by: [asc: matches.inserted_at]
    )
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :members) do
    from(match in query,
      left_join: members in assoc(match, :members),
      preload: [members: members]
    )
  end

  def _preload(query, :settings) do
    from(match in query,
      left_join: settings in assoc(match, :settings),
      preload: [settings: settings]
    )
  end
end
