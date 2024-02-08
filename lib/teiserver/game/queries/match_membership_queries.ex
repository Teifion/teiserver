defmodule Teiserver.Game.MatchMembershipQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Game.MatchMembership
  require Logger

  @spec match_membership_query(Teiserver.query_args()) :: Ecto.Query.t()
  def match_membership_query(args) do
    query = from(match_memberships in MatchMembership)

    query
    |> do_where(match_id: args[:match_id])
    |> do_where(user_id: args[:user_id])
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

  def _where(query, :match_id, match_ids) when is_list(match_ids) do
    from(match_memberships in query,
      where: match_memberships.match_id in ^match_ids
    )
  end

  def _where(query, :match_id, match_id) do
    from(match_memberships in query,
      where: match_memberships.match_id == ^match_id
    )
  end

  def _where(query, :user_id, user_ids) when is_list(user_ids) do
    from(match_memberships in query,
      where: match_memberships.user_id in ^user_ids
    )
  end

  def _where(query, :user_id, user_id) do
    from(match_memberships in query,
      where: match_memberships.user_id == ^user_id
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
    from(match_memberships in query,
      order_by: [asc: match_memberships.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(match_memberships in query,
      order_by: [desc: match_memberships.name]
    )
  end

  def _order_by(query, "Newest first") do
    from(match_memberships in query,
      order_by: [desc: match_memberships.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(match_memberships in query,
      order_by: [asc: match_memberships.inserted_at]
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
  #   from match_membership in query,
  #     left_join: relations in assoc(match_membership, :relation),
  #     preload: [relation: relations]
  # end

  # def _preload(query, {:relation, join_query}) do
  #   from match_membership in query,
  #     left_join: relations in subquery(join_query),
  #       on: relations.id == query.relation_id,
  #     preload: [relation: relations]
  # end
end
