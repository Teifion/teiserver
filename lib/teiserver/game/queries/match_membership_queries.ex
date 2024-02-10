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

  def _where(query, :win?, win?) do
    from(match_memberships in query,
      where: match_memberships.win? == ^win?
    )
  end

  def _where(query, :party_id, party_ids) when is_list(party_ids) do
    from(match_memberships in query,
      where: match_memberships.party_id in ^party_ids
    )
  end

  def _where(query, :party_id, party_id) do
    from(match_memberships in query,
      where: match_memberships.party_id == ^party_id
    )
  end

  def _where(query, :team_number, team_numbers) when is_list(team_numbers) do
    from(match_memberships in query,
      where: match_memberships.team_number in ^team_numbers
    )
  end

  def _where(query, :team_number, team_number) do
    from(match_memberships in query,
      where: match_memberships.team_number == ^team_number
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
  def _order_by(query, "First to leave") do
    from(match_memberships in query,
      order_by: [asc: match_memberships.left_after_seconds]
    )
  end

  def _order_by(query, "Last to leave") do
    from(match_memberships in query,
      order_by: [desc: match_memberships.left_after_seconds]
    )
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :user) do
    from match_membership in query,
      left_join: users in assoc(match_membership, :user),
      preload: [user: users]
  end

  def _preload(query, :match) do
    from match_membership in query,
      left_join: matches in assoc(match_membership, :match),
      preload: [match: matches]
  end
end
