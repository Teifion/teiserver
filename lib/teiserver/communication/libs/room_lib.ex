defmodule Teiserver.Communication.RoomLib do
  @moduledoc """
  Library of room related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Communication.{Room, RoomQueries}

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  @spec list_rooms(list) :: list
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
  @spec get_room!(non_neg_integer()) :: Room.t()
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
  @spec get_room(non_neg_integer(), list) :: Room.t() | nil
  def get_room(room_id, query_args \\ []) do
    (query_args ++ [id: room_id])
    |> RoomQueries.room_query()
    |> Repo.one
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_room(map) :: {:ok, Room.t} | {:error, Ecto.Changeset.t}
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_room(Room.t, map) :: {:ok, Room.t} | {:error, Ecto.Changeset.t}
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
  @spec delete_room(Room.t) :: {:ok, Room.t} | {:error, Ecto.Changeset.t}
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  @spec change_room(Room.t, map) :: Ecto.Changeset.t
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end
end
