defmodule Teiserver.System.ClusterMemberQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.System.ClusterMember
  require Logger

  @spec cluster_member_query(Teiserver.query_args()) :: Ecto.Query.t()
  def cluster_member_query(args) do
    query = from(cluster_members in ClusterMember)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  def do_where(query, nil), do: query

  def do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), atom, any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id_list) when is_list(id_list) do
    from(cluster_members in query,
      where: cluster_members.id in ^id_list
    )
  end

  def _where(query, :id, id) do
    from(cluster_members in query,
      where: cluster_members.id == ^id
    )
  end

  def _where(query, :host, host_list) when is_list(host_list) do
    from(cluster_members in query,
      where: cluster_members.host in ^host_list
    )
  end

  def _where(query, :host, host) do
    from(cluster_members in query,
      where: cluster_members.host == ^host
    )
  end

  def _where(query, :host_not, host) do
    from(cluster_members in query,
      where: cluster_members.host != ^host
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
  def _order_by(query, "Host (A-Z)") do
    from(cluster_members in query,
      order_by: [asc: cluster_members.host]
    )
  end

  def _order_by(query, "Host (Z-A)") do
    from(cluster_members in query,
      order_by: [desc: cluster_members.host]
    )
  end

  def _order_by(query, "Newest first") do
    from(cluster_members in query,
      order_by: [desc: cluster_members.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(cluster_members in query,
      order_by: [asc: cluster_members.inserted_at]
    )
  end
end
