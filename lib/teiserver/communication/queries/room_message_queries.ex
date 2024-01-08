defmodule Teiserver.Communication.RoomMessageQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Communication.RoomMessage
  require Logger

  @spec room_message_query(list) :: Ecto.Query.t()
  def room_message_query(args) do
    query = from(room_messages in RoomMessage)

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
    from room_messages in query,
      where: room_messages.id == ^id
  end

  def _where(query, :id_in, id_list) do
    from room_messages in query,
      where: room_messages.id in ^id_list
  end

  def _where(query, :name, name) do
    from room_messages in query,
      where: room_messages.name == ^name
  end


  def _where(query, :inserted_after, timestamp) do
    from room_messages in query,
      where: room_messages.inserted_at >= ^timestamp
  end

  def _where(query, :inserted_before, timestamp) do
    from room_messages in query,
      where: room_messages.inserted_at < ^timestamp
  end


  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) when is_list(params) do
    params
    |> List.wrap
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Name (A-Z)") do
    from room_messages in query,
      order_by: [asc: room_messages.name]
  end

  def _order_by(query, "Name (Z-A)") do
    from room_messages in query,
      order_by: [desc: room_messages.name]
  end

  def _order_by(query, "Newest first") do
    from room_messages in query,
      order_by: [desc: room_messages.inserted_at]
  end

  def _order_by(query, "Oldest first") do
    from room_messages in query,
      order_by: [asc: room_messages.inserted_at]
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
  def _preload(query, :room) do
    from room_message in query,
      left_join: rooms in assoc(room_message, :room),
      preload: [room: rooms]
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :from) do
    from room_message in query,
      left_join: froms in assoc(room_message, :from),
      preload: [from: froms]
  end
end
