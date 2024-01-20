defmodule Teiserver.Communication.DirectMessageQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Communication.DirectMessage
  require Logger

  @spec direct_message_query(list) :: Ecto.Query.t()
  def direct_message_query(args) do
    query = from(direct_messages in DirectMessage)

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
  def do_where(query, nil), do: query

  def do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query
  def _where(query, _, "Any"), do: query

  def _where(query, :id_in, id_list) when is_list(id_list) do
    from(direct_messages in query,
      where: direct_messages.id in ^id_list
    )
  end

  def _where(query, :id, id) do
    from(direct_messages in query,
      where: direct_messages.id == ^id
    )
  end

  def _where(query, :to_id, to_id_list) when is_list(to_id_list) do
    from(direct_messages in query,
      where: direct_messages.to_id in ^to_id_list
    )
  end

  def _where(query, :to_id, to_id) do
    from(direct_messages in query,
      where: direct_messages.to_id == ^to_id
    )
  end

  def _where(query, :from_id, from_id_list) when is_list(from_id_list) do
    from(direct_messages in query,
      where: direct_messages.from_id in ^from_id_list
    )
  end

  def _where(query, :from_id, from_id) do
    from(direct_messages in query,
      where: direct_messages.from_id == ^from_id
    )
  end

  def _where(query, :to_or_from_id, user_ids) when is_list(user_ids) do
    from(direct_messages in query,
      where: (direct_messages.from_id in ^user_ids or direct_messages.to_id in ^user_ids)
    )
  end

  def _where(query, :to_or_from_id, user_id) do
    from(direct_messages in query,
      where: (direct_messages.from_id == ^user_id or direct_messages.to_id == ^user_id)
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(direct_messages in query,
      where: direct_messages.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(direct_messages in query,
      where: direct_messages.inserted_at < ^timestamp
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
    from(direct_messages in query,
      order_by: [asc: direct_messages.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(direct_messages in query,
      order_by: [desc: direct_messages.name]
    )
  end

  def _order_by(query, "Newest first") do
    from(direct_messages in query,
      order_by: [desc: direct_messages.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(direct_messages in query,
      order_by: [asc: direct_messages.inserted_at]
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
  def _preload(query, :from) do
    from(direct_message in query,
      left_join: froms in assoc(direct_message, :from),
      preload: [from: froms]
    )
  end

  def _preload(query, :to) do
    from(direct_message in query,
      left_join: tos in assoc(direct_message, :to),
      preload: [to: tos]
    )
  end
end
