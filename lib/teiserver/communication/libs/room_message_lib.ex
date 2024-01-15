defmodule Teiserver.Communication.RoomMessageLib do
  @moduledoc """
  Library of room_message related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Communication.{RoomMessage, RoomMessageQueries}

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
  @spec get_room_message!(non_neg_integer()) :: RoomMessage.t()
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
  @spec get_room_message(non_neg_integer(), list) :: RoomMessage.t() | nil
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
