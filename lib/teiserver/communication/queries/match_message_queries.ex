defmodule Teiserver.Communication.MatchMessageQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Communication.MatchMessage
  require Logger

  @spec match_message_query(Teiserver.query_args()) :: Ecto.Query.t()
  def match_message_query(args) do
    query = from(match_messages in MatchMessage)

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
    from(match_messages in query,
      where: match_messages.id in ^id_list
    )
  end

  def _where(query, :id, id) do
    from(match_messages in query,
      where: match_messages.id == ^id
    )
  end

  def _where(query, :match_id, match_ids) when is_list(match_ids) do
    from(match_messages in query,
      where: match_messages.match_id in ^match_ids
    )
  end

  def _where(query, :match_id, match_id) do
    from(match_messages in query,
      where: match_messages.match_id == ^match_id
    )
  end

  def _where(query, :sender_id, sender_ids) when is_list(sender_ids) do
    from(match_messages in query,
      where: match_messages.sender_id in ^sender_ids
    )
  end

  def _where(query, :sender_id, sender_id) do
    from(match_messages in query,
      where: match_messages.sender_id == ^sender_id
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(match_messages in query,
      where: match_messages.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(match_messages in query,
      where: match_messages.inserted_at < ^timestamp
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
  def _order_by(query, "Newest first") do
    from(match_messages in query,
      order_by: [desc: match_messages.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(match_messages in query,
      order_by: [asc: match_messages.inserted_at]
    )
  end

  @spec do_preload(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :match) do
    from(match_message in query,
      left_join: matches in assoc(match_message, :match),
      preload: [match: matches]
    )
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :sender) do
    from(match_message in query,
      left_join: senders in assoc(match_message, :sender),
      preload: [sender: senders]
    )
  end
end
