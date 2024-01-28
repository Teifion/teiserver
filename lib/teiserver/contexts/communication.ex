defmodule Teiserver.Communication do
  @moduledoc """
  The contextual module for:
  - `Teiserver.Communication.Room`
  - `Teiserver.Communication.RoomMessage`
  - `Teiserver.Communication.DirectMessage`
  - `Teiserver.Communication.LobbyMessage`
  - `Teiserver.Communication.PartyMessage`
  """

  alias Teiserver.Communication.{Room, RoomLib, RoomQueries}

  @doc false
  @spec room_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate room_query(args \\ []), to: RoomQueries

  @doc section: :room
  @spec list_rooms(Teiserver.query_args()) :: [Room.t()]
  defdelegate list_rooms(args), to: RoomLib

  @doc section: :room
  @spec get_room!(non_neg_integer()) :: Room.t()
  @spec get_room!(non_neg_integer(), Teiserver.query_args()) :: Room.t()
  defdelegate get_room!(room_id, query_args \\ []), to: RoomLib

  @doc section: :room
  @spec get_room(non_neg_integer()) :: Room.t() | nil
  @spec get_room(non_neg_integer(), Teiserver.query_args()) :: Room.t() | nil
  defdelegate get_room(room_id, query_args \\ []), to: RoomLib

  @doc section: :room
  @spec get_room_by_name_or_id(Room.name_or_id()) :: Room.t() | nil
  defdelegate get_room_by_name_or_id(room_name_or_id), to: RoomLib

  @doc section: :room
  @spec create_room(map) :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_room(attrs \\ %{}), to: RoomLib

  @doc section: :room
  @spec get_or_create_room(Room.name()) :: Room.t()
  defdelegate get_or_create_room(room_name), to: RoomLib

  @doc section: :room
  @spec update_room(Room, map) :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_room(room, attrs), to: RoomLib

  @doc section: :room
  @spec delete_room(Room.t()) :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_room(room), to: RoomLib

  @doc section: :room
  @spec change_room(Room.t(), map) :: Ecto.Changeset.t()
  defdelegate change_room(room, attrs \\ %{}), to: RoomLib

  alias Teiserver.Communication.{RoomMessage, RoomMessageLib, RoomMessageQueries}

  @doc section: :room_message
  @spec send_room_message(Teiserver.user_id(), Room.id(), String.t(), map()) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate send_room_message(sender_id, room_id, content, attrs \\ %{}), to: RoomMessageLib

  @doc section: :room_message
  @spec list_recent_room_messages(Room.id(), non_neg_integer()) :: [RoomMessage.t()]
  defdelegate list_recent_room_messages(room_name_or_id, limit \\ 50), to: RoomMessageLib

  @doc false
  @spec room_message_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate room_message_query(args), to: RoomMessageQueries

  @doc section: :room_message
  @spec list_room_messages(Teiserver.query_args()) :: [RoomMessage.t()]
  defdelegate list_room_messages(args), to: RoomMessageLib

  @doc section: :room_message
  @spec get_room_message!(non_neg_integer(), list) :: RoomMessage.t()
  defdelegate get_room_message!(room_message_id, query_args \\ []), to: RoomMessageLib

  @doc section: :room_message
  @spec get_room_message(non_neg_integer(), list) :: RoomMessage.t() | nil
  defdelegate get_room_message(room_message_id, query_args \\ []), to: RoomMessageLib

  @doc section: :room_message
  @spec create_room_message(map) :: {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_room_message(attrs \\ %{}), to: RoomMessageLib

  @doc section: :room_message
  @spec update_room_message(RoomMessage, map) :: {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_room_message(room_message, attrs), to: RoomMessageLib

  @doc section: :room_message
  @spec delete_room_message(RoomMessage.t()) :: {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_room_message(room_message), to: RoomMessageLib

  @doc section: :room_message
  @spec change_room_message(RoomMessage.t(), map) :: Ecto.Changeset.t()
  defdelegate change_room_message(room_message, attrs \\ %{}), to: RoomMessageLib

  alias Teiserver.Communication.{DirectMessage, DirectMessageLib, DirectMessageQueries}

  @doc false
  @spec direct_message_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate direct_message_query(args), to: DirectMessageQueries

  @doc section: :direct_message
  @spec list_direct_messages(list) :: [DirectMessage.t()]
  defdelegate list_direct_messages(args), to: DirectMessageLib

  @doc section: :direct_message
  @spec get_direct_message!(non_neg_integer(), list) :: DirectMessage.t()
  defdelegate get_direct_message!(direct_message_id, query_args \\ []), to: DirectMessageLib

  @doc section: :direct_message
  @spec get_direct_message(non_neg_integer(), list) :: DirectMessage.t() | nil
  defdelegate get_direct_message(direct_message_id, query_args \\ []), to: DirectMessageLib

  @doc section: :direct_message
  @spec create_direct_message(map) :: {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_direct_message(attrs \\ %{}), to: DirectMessageLib

  @doc section: :direct_message
  @spec update_direct_message(DirectMessage, map) ::
          {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_direct_message(direct_message, attrs), to: DirectMessageLib

  @doc section: :direct_message
  @spec delete_direct_message(DirectMessage.t()) ::
          {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_direct_message(direct_message), to: DirectMessageLib

  @doc section: :direct_message
  @spec change_direct_message(DirectMessage.t(), map) :: Ecto.Changeset.t()
  defdelegate change_direct_message(direct_message, attrs \\ %{}), to: DirectMessageLib

  @doc section: :direct_message
  @spec send_direct_message(Teiserver.user_id(), Teiserver.user_id(), String.t(), map()) ::
          {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate send_direct_message(from_id, to_id, content, attrs \\ %{}), to: DirectMessageLib

  @doc section: :direct_message
  @spec list_direct_messages_from_user_to_user(Teiserver.user_id(), Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_from_user_to_user(Teiserver.user_id(), Teiserver.user_id(), Teiserver.query_args()) :: [DirectMessage.t()]
  defdelegate list_direct_messages_from_user_to_user(from_id, to_id, query_args \\ []), to: DirectMessageLib

  @doc section: :direct_message
  @spec list_direct_messages_for_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_for_user(Teiserver.user_id(), Teiserver.query_args()) :: [DirectMessage.t()]
  defdelegate list_direct_messages_for_user(user_id, query_args \\ []), to: DirectMessageLib

  @doc section: :direct_message
  @spec list_direct_messages_to_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_to_user(Teiserver.user_id(), Teiserver.query_args()) :: [DirectMessage.t()]
  defdelegate list_direct_messages_to_user(user_id, query_args \\ []), to: DirectMessageLib

  @doc section: :direct_message
  @spec list_direct_messages_from_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_from_user(Teiserver.user_id(), Teiserver.query_args()) :: [DirectMessage.t()]
  defdelegate list_direct_messages_from_user(user_id, query_args \\ []), to: DirectMessageLib

  @spec list_direct_messages_between_users(Teiserver.user_id(), Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_between_users(Teiserver.user_id(), Teiserver.user_id(), Teiserver.query_args()) :: [DirectMessage.t()]
  defdelegate list_direct_messages_between_users(user_id1, user_id2, query_args \\ []), to: DirectMessageLib

  # Party chat
end
