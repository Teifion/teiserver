defmodule Teiserver.Communication.RoomLib do
  @moduledoc """
  Library of room related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Communication.{Room, RoomQueries}

  @doc false
  @spec room_topic(Room.id() | Room.t()) :: String.t()
  def room_topic(%Room{id: room_id}), do: "Teiserver.Communication.Room.#{room_id}"
  def room_topic(room_id), do: "Teiserver.Communication.Room.#{room_id}"

  @doc """
  Joins your process to room messages
  """
  @spec subscribe_to_room(Room.id() | Room.t() | String.t()) :: :ok
  def subscribe_to_room(room_id) when is_integer(room_id) do
    room_id
    |> room_topic()
    |> Teiserver.subscribe()
  end

  def subscribe_to_room(%Room{id: room_id}), do: subscribe_to_room(room_id)
  def subscribe_to_room(room_name), do: get_or_create_room(room_name).id

  @doc """
  Removes your process from a room's messages
  """
  @spec unsubscribe_from_room(Room.id() | Room.t() | String.t()) :: :ok
  def unsubscribe_from_room(room_id) when is_integer(room_id) do
    room_id
    |> room_topic()
    |> Teiserver.unsubscribe()
  end

  def unsubscribe_from_room(%Room{id: room_id}), do: unsubscribe_from_room(room_id)
  def unsubscribe_from_room(room_name), do: get_or_create_room(room_name).id

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  @spec list_rooms(Teiserver.query_args()) :: [Room.t()]
  def list_rooms(query_args \\ []) do
    query_args
    |> RoomQueries.room_query()
    |> Repo.all()
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_room!(Room.id()) :: Room.t()
  @spec get_room!(Room.id(), Teiserver.query_args()) :: Room.t()
  def get_room!(room_id, query_args \\ []) do
    (query_args ++ [id: room_id])
    |> RoomQueries.room_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single room.

  Returns nil if the Room does not exist.

  ## Examples

      iex> get_room(123)
      %Room{}

      iex> get_room(456)
      nil

  """
  @spec get_room(Room.id()) :: Room.t() | nil
  @spec get_room(Room.id(), Teiserver.query_args()) :: Room.t() | nil
  def get_room(room_id, query_args \\ []) do
    (query_args ++ [id: room_id])
    |> RoomQueries.room_query()
    |> Repo.one()
  end

  @doc """
  Gets a single room by name or id (must be an integer).

  Returns nil if the Room does not exist.

  ## Examples

      iex> get_room_by_name_or_id("main")
      %Room{}

      iex> get_room_by_name_or_id(123)
      %Room{}

      iex> get_room_by_name_or_id("not a name")
      nil

      iex> get_room_by_name_or_id(456)
      nil

  """
  @spec get_room_by_name_or_id(String.t() | Room.id()) :: Room.t() | nil
  def get_room_by_name_or_id(room_id) when is_integer(room_id) do
    get_room(room_id)
  end

  def get_room_by_name_or_id(room_name) do
    RoomQueries.room_query(where: [name: room_name])
    |> Repo.one()
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_room(map) :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a room of a given name, if the room does not exist it is created.

  ## Examples

      iex> get_or_create_room("name")
      %Room{}

      iex> get_or_create_room("not a room"")
      %Room{}

  """
  @spec get_or_create_room(String.t()) :: Room.t()
  def get_or_create_room(room_name) do
    case get_room_by_name_or_id(room_name) do
      nil ->
        {:ok, room} = create_room(%{name: room_name})
        room

      room ->
        room
    end
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_room(Room.t(), map) :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_room(Room.t()) :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  @spec change_room(Room.t(), map) :: Ecto.Changeset.t()
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end
end
