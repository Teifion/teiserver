defmodule Teiserver.Communication.RoomMessageLib do
  @moduledoc """
  Library of room_message related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Communication.{Room, RoomLib, RoomMessage, RoomMessageQueries}

  @doc """
  Returns a list of messages from a room ordered as the newest first.

  In the event of there being ne messages for a room of that ID the function will return an empty list.

  ## Examples

      iex> list_recent_room_messages(123)
      [%RoomMessage{}, ...]

      iex> list_recent_room_messages(456)
      []
  """
  @spec list_recent_room_messages(Room.id(), non_neg_integer()) :: [RoomMessage.t()]
  def list_recent_room_messages(room_id, limit \\ 50) when is_integer(room_id) do
    list_room_messages(where: [room_id: room_id], limit: limit, order_by: ["Newest first"])
  end

  @doc """
    - Creates a room message
    - If successful generate a pubsub message

    ## Examples

        iex> send_room_message(123, 123, "Message content")
        {:ok, %RoomMessage{}}

        iex> send_room_message(456, 456, "Message content")
        {:error, %Ecto.Changeset{}}
  """
  @spec send_room_message(Teiserver.user_id(), Room.id(), String.t(), map()) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  def send_room_message(sender_id, room_id, content, attrs \\ %{}) do
    attrs =
      Map.merge(
        %{
          sender_id: sender_id,
          room_id: room_id,
          content: content,
          inserted_at: Timex.now()
        },
        attrs
      )

    case create_room_message(attrs) do
      {:ok, room_message} ->
        topic = RoomLib.room_topic(room_message.room_id)

        Teiserver.broadcast(
          topic,
          %{
            event: :message_received,
            room_message: room_message
          }
        )

        {:ok, room_message}

      err ->
        err
    end
  end

  @doc """
  Returns the list of room_messages.

  ## Examples

      iex> list_room_messages()
      [%RoomMessage{}, ...]

  """
  @spec list_room_messages(list) :: list
  def list_room_messages(query_args \\ []) do
    query_args
    |> RoomMessageQueries.room_message_query()
    |> Repo.all()
  end

  @doc """
  Gets a single room_message.

  Raises `Ecto.NoResultsError` if the RoomMessage does not exist.

  ## Examples

      iex> get_room_message!(123)
      %RoomMessage{}

      iex> get_room_message!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_room_message!(RoomMessage.id()) :: RoomMessage.t()
  @spec get_room_message!(RoomMessage.id(), Teiserver.query_args()) :: RoomMessage.t()
  def get_room_message!(room_message_id, query_args \\ []) do
    (query_args ++ [id: room_message_id])
    |> RoomMessageQueries.room_message_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single room_message.

  Returns nil if the RoomMessage does not exist.

  ## Examples

      iex> get_room_message(123)
      %RoomMessage{}

      iex> get_room_message(456)
      nil

  """
  @spec get_room_message(RoomMessage.id()) :: RoomMessage.t() | nil
  @spec get_room_message(RoomMessage.id(), Teiserver.query_args()) :: RoomMessage.t() | nil
  def get_room_message(room_message_id, query_args \\ []) do
    (query_args ++ [id: room_message_id])
    |> RoomMessageQueries.room_message_query()
    |> Repo.one()
  end

  @doc """
  Creates a room_message.

  ## Examples

      iex> create_room_message(%{field: value})
      {:ok, %RoomMessage{}}

      iex> create_room_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_room_message(map) :: {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  def create_room_message(attrs \\ %{}) do
    %RoomMessage{}
    |> RoomMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room_message.

  ## Examples

      iex> update_room_message(room_message, %{field: new_value})
      {:ok, %RoomMessage{}}

      iex> update_room_message(room_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_room_message(RoomMessage.t(), map) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  def update_room_message(%RoomMessage{} = room_message, attrs) do
    room_message
    |> RoomMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room_message.

  ## Examples

      iex> delete_room_message(room_message)
      {:ok, %RoomMessage{}}

      iex> delete_room_message(room_message)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_room_message(RoomMessage.t()) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  def delete_room_message(%RoomMessage{} = room_message) do
    Repo.delete(room_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room_message changes.

  ## Examples

      iex> change_room_message(room_message)
      %Ecto.Changeset{data: %RoomMessage{}}

  """
  @spec change_room_message(RoomMessage.t(), map) :: Ecto.Changeset.t()
  def change_room_message(%RoomMessage{} = room_message, attrs \\ %{}) do
    RoomMessage.changeset(room_message, attrs)
  end
end
