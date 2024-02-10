defmodule Teiserver.Communication do
  @moduledoc """
  The contextual module for:
  - `Teiserver.Communication.Room`
  - `Teiserver.Communication.RoomMessage`
  - `Teiserver.Communication.DirectMessage`
  - `Teiserver.Communication.MatchMessage`
  - `Teiserver.Communication.PartyMessage`
  """
  alias Teiserver.Account.User
  alias Teiserver.Communication.{Room, RoomLib, RoomQueries}

  @doc false
  @spec room_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate room_query(args \\ []), to: RoomQueries

  @doc section: :room
  @spec list_rooms(Teiserver.query_args()) :: [Room.t()]
  defdelegate list_rooms(args), to: RoomLib

  @doc section: :room
  @spec get_room!(Room.id()) :: Room.t()
  @spec get_room!(Room.id(), Teiserver.query_args()) :: Room.t()
  defdelegate get_room!(room_id, query_args \\ []), to: RoomLib

  @doc section: :room
  @spec get_room(Room.id()) :: Room.t() | nil
  @spec get_room(Room.id(), Teiserver.query_args()) :: Room.t() | nil
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
  @spec room_messaging_topic(Room.id() | Room.t()) :: String.t()
  defdelegate room_messaging_topic(room_or_room_id), to: RoomMessageLib

  @doc section: :room_message
  @spec subscribe_to_room_messages(Room.id() | Room.t()) :: :ok
  defdelegate subscribe_to_room_messages(room_or_room_id), to: RoomMessageLib

  @doc section: :room_message
  @spec unsubscribe_from_room_messages(Room.id() | Room.t()) :: :ok
  defdelegate unsubscribe_from_room_messages(room_or_room_id), to: RoomMessageLib

  @doc false
  @spec room_message_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate room_message_query(args), to: RoomMessageQueries

  @doc section: :room_message
  @spec list_room_messages(Teiserver.query_args()) :: [RoomMessage.t()]
  defdelegate list_room_messages(args), to: RoomMessageLib

  @doc section: :room_message
  @spec get_room_message!(RoomMessage.id()) :: RoomMessage.t()
  @spec get_room_message!(RoomMessage.id(), Teiserver.query_args()) :: RoomMessage.t()
  defdelegate get_room_message!(room_message_id, query_args \\ []), to: RoomMessageLib

  @doc section: :room_message
  @spec get_room_message(RoomMessage.id()) :: RoomMessage.t() | nil
  @spec get_room_message(RoomMessage.id(), Teiserver.query_args()) :: RoomMessage.t() | nil
  defdelegate get_room_message(room_message_id, query_args \\ []), to: RoomMessageLib

  @doc section: :room_message
  @spec create_room_message(map) :: {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_room_message(attrs \\ %{}), to: RoomMessageLib

  @doc section: :room_message
  @spec update_room_message(RoomMessage, map) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_room_message(room_message, attrs), to: RoomMessageLib

  @doc section: :room_message
  @spec delete_room_message(RoomMessage.t()) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_room_message(room_message), to: RoomMessageLib

  @doc section: :room_message
  @spec change_room_message(RoomMessage.t(), map) :: Ecto.Changeset.t()
  defdelegate change_room_message(room_message, attrs \\ %{}), to: RoomMessageLib

  alias Teiserver.Communication.{DirectMessage, DirectMessageLib, DirectMessageQueries}

  @doc false
  @spec user_messaging_topic(Teiserver.user_id() | User.t()) :: String.t()
  defdelegate user_messaging_topic(room_or_room_id), to: DirectMessageLib

  @doc section: :direct_message
  @spec subscribe_to_user_messaging(User.id() | User.t()) :: :ok
  defdelegate subscribe_to_user_messaging(user_or_user_id), to: DirectMessageLib

  @doc section: :direct_message
  @spec unsubscribe_from_user_messaging(User.id() | User.t()) :: :ok
  defdelegate unsubscribe_from_user_messaging(user_or_user_id), to: DirectMessageLib

  @doc false
  @spec direct_message_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate direct_message_query(args), to: DirectMessageQueries

  @doc section: :direct_message
  @spec list_direct_messages(list) :: [DirectMessage.t()]
  defdelegate list_direct_messages(args), to: DirectMessageLib

  @doc section: :direct_message
  @spec get_direct_message!(DirectMessage.id()) :: DirectMessage.t()
  @spec get_direct_message!(DirectMessage.id(), Teiserver.query_args()) :: DirectMessage.t()
  defdelegate get_direct_message!(direct_message_id, query_args \\ []), to: DirectMessageLib

  @doc section: :direct_message
  @spec get_direct_message(DirectMessage.id()) :: DirectMessage.t() | nil
  @spec get_direct_message(DirectMessage.id(), Teiserver.query_args()) :: DirectMessage.t() | nil
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
  @spec list_direct_messages_from_user_to_user(Teiserver.user_id(), Teiserver.user_id()) :: [
          DirectMessage.t()
        ]
  @spec list_direct_messages_from_user_to_user(
          Teiserver.user_id(),
          Teiserver.user_id(),
          Teiserver.query_args()
        ) :: [DirectMessage.t()]
  defdelegate list_direct_messages_from_user_to_user(from_id, to_id, query_args \\ []),
    to: DirectMessageLib

  @doc section: :direct_message
  @spec list_direct_messages_for_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_for_user(Teiserver.user_id(), Teiserver.query_args()) :: [
          DirectMessage.t()
        ]
  defdelegate list_direct_messages_for_user(user_id, query_args \\ []), to: DirectMessageLib

  @doc section: :direct_message
  @spec list_direct_messages_to_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_to_user(Teiserver.user_id(), Teiserver.query_args()) :: [
          DirectMessage.t()
        ]
  defdelegate list_direct_messages_to_user(user_id, query_args \\ []), to: DirectMessageLib

  @doc section: :direct_message
  @spec list_direct_messages_from_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_from_user(Teiserver.user_id(), Teiserver.query_args()) :: [
          DirectMessage.t()
        ]
  defdelegate list_direct_messages_from_user(user_id, query_args \\ []), to: DirectMessageLib

  @spec list_direct_messages_between_users(Teiserver.user_id(), Teiserver.user_id()) :: [
          DirectMessage.t()
        ]
  @spec list_direct_messages_between_users(
          Teiserver.user_id(),
          Teiserver.user_id(),
          Teiserver.query_args()
        ) :: [DirectMessage.t()]
  defdelegate list_direct_messages_between_users(user_id1, user_id2, query_args \\ []),
    to: DirectMessageLib

  # Party chat

  # Match chat
  alias Teiserver.Communication.{MatchMessage, MatchMessageLib, MatchMessageQueries}
  alias Teiserver.Game.Match

  @doc false
  @spec match_messaging_topic(Teiserver.match_id() | Match.t()) :: String.t()
  defdelegate match_messaging_topic(match_or_match_id), to: MatchMessageLib

  @doc section: :match_message
  @spec subscribe_to_match_messages(Match.id() | Match.t()) :: :ok
  defdelegate subscribe_to_match_messages(match_or_match_id), to: MatchMessageLib

  @doc section: :match_message
  @spec unsubscribe_from_match_messages(Match.id() | Match.t()) :: :ok
  defdelegate unsubscribe_from_match_messages(match_or_match_id), to: MatchMessageLib

  @doc section: :match_message
  @spec send_match_message(Teiserver.user_id(), Match.id(), String.t(), map()) ::
          {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate send_match_message(sender_id, match_id, content, attrs \\ %{}), to: MatchMessageLib

  @doc section: :match_message
  @spec list_recent_match_messages(Match.id(), non_neg_integer()) :: [MatchMessage.t()]
  defdelegate list_recent_match_messages(match_name_or_id, limit \\ 50), to: MatchMessageLib

  @doc false
  @spec match_message_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate match_message_query(args), to: MatchMessageQueries

  @doc section: :match_message
  @spec list_match_messages(Teiserver.query_args()) :: [MatchMessage.t()]
  defdelegate list_match_messages(args), to: MatchMessageLib

  @doc section: :match_message
  @spec get_match_message!(MatchMessage.id()) :: MatchMessage.t()
  @spec get_match_message!(MatchMessage.id(), Teiserver.query_args()) :: MatchMessage.t()
  defdelegate get_match_message!(match_message_id, query_args \\ []), to: MatchMessageLib

  @doc section: :match_message
  @spec get_match_message(MatchMessage.id()) :: MatchMessage.t() | nil
  @spec get_match_message(MatchMessage.id(), Teiserver.query_args()) :: MatchMessage.t() | nil
  defdelegate get_match_message(match_message_id, query_args \\ []), to: MatchMessageLib

  @doc section: :match_message
  @spec create_match_message(map) :: {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_match_message(attrs \\ %{}), to: MatchMessageLib

  @doc section: :match_message
  @spec update_match_message(MatchMessage, map) ::
          {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_match_message(match_message, attrs), to: MatchMessageLib

  @doc section: :match_message
  @spec delete_match_message(MatchMessage.t()) ::
          {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_match_message(match_message), to: MatchMessageLib

  @doc section: :match_message
  @spec change_match_message(MatchMessage.t(), map) :: Ecto.Changeset.t()
  defdelegate change_match_message(match_message, attrs \\ %{}), to: MatchMessageLib
end
