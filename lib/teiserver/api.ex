defmodule Teiserver.Api do
  @moduledoc """
  A set of functions for a basic usage of Teiserver. The purpose is
  to allow you to start with importing only this module and then
  import others as your needs grow more complex.
  """

  alias Teiserver.{Account, Communication, Connections}
  alias Account.UserLib

  alias Connections.ClientLib

  alias Communication.{
    Room,
    RoomLib,
    RoomMessage,
    RoomMessageLib,
    DirectMessage,
    DirectMessageLib,
    MatchMessage,
    MatchMessageLib
  }

  alias Teiserver.Game.{
    Lobby,
    LobbyLib,
    Match,
    MatchLib
  }

  @doc """
  Takes a name and password, tries to authenticate the user.

  ## Examples

      iex> maybe_authenticate_user("Alice", "password1")
      {:ok, %User{}}

      iex> maybe_authenticate_user("Bob", "bad password")
      {:error, :bad_password}

      iex> maybe_authenticate_user("Chris", "password1")
      {:error, :no_user}
  """
  @doc section: :user
  @spec maybe_authenticate_user(String.t(), String.t()) ::
          {:ok, Account.User.t()} | {:error, :no_user | :bad_password}
  def maybe_authenticate_user(name, password) do
    case Account.get_user_by_name(name) do
      nil ->
        {:error, :no_user}

      user ->
        if Teiserver.Account.verify_user_password(user, password) do
          {:ok, user}
        else
          {:error, :bad_password}
        end
    end
  end

  @doc """
  Makes use of `Teiserver.Connections.ClientLib.connect_user/1` to connect
  and then also subscribes you to the following pubsubs:
  - [Teiserver.Connections.Client](documentation/pubsubs/client.md#teiserver-connections-client-user_id)
  - [Teiserver.Communication.User](documentation/pubsubs/communication.md#teiserver-communication-user-user_id)

  Always returns `:ok`
  """
  @doc section: :client
  @spec connect_user(Teiserver.user_id()) :: Connections.Client.t()
  def connect_user(user_id) when is_binary(user_id) do
    Connections.connect_user(user_id)
    # Sleep to prevent this current process getting the messages related to the connection
    :timer.sleep(100)
    Teiserver.subscribe(Connections.client_topic(user_id))
    Teiserver.subscribe(Communication.user_messaging_topic(user_id))
  end

  @doc """
  Takes a name, email and password. Creates a user with them.

  ## Examples

      iex> register_user("Alice", "alice@alice", "password1")
      {:ok, %User{}}

      iex> register_user("Bob", "bob@bob", "1")
      {:error, %Ecto.Changeset{}}
  """
  @doc section: :user
  @spec register_user(String.t(), String.t(), String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(name, email, password) do
    Teiserver.Account.register_user(%{
      "name" => name,
      "password" => password,
      "email" => email
    })
  end

  ### Account
  @doc section: :user
  @spec get_user_by_id(Teiserver.user_id()) :: User.t() | nil
  defdelegate get_user_by_id(user_id), to: UserLib

  @doc section: :user
  @spec get_user_by_name(String.t()) :: User.t() | nil
  defdelegate get_user_by_name(name), to: UserLib

  ### Connections
  # Client
  @doc section: :client
  @spec get_client(Teiserver.user_id()) :: Client.t() | nil
  defdelegate get_client(user_id), to: ClientLib

  ### Game
  # Lobby
  @doc section: :lobby
  @spec subscribe_to_lobby(Lobby.id() | Lobby.t()) :: :ok
  defdelegate subscribe_to_lobby(lobby_or_lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec unsubscribe_from_lobby(Lobby.id() | Lobby.t()) :: :ok
  defdelegate unsubscribe_from_lobby(lobby_or_lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec get_lobby(Lobby.id()) :: Lobby.t() | nil
  defdelegate get_lobby(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec get_lobby_summary(Lobby.id()) :: LobbySummary.t() | nil
  defdelegate get_lobby_summary(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec update_lobby(Lobby.id(), map) :: :ok | nil
  defdelegate update_lobby(lobby_id, value_map), to: LobbyLib

  @doc section: :lobby
  @spec list_lobby_ids() :: [Lobby.id()]
  defdelegate list_lobby_ids, to: LobbyLib

  @doc section: :lobby
  @spec stream_lobby_summaries() :: Enumerable.t(LobbySummary.t())
  defdelegate stream_lobby_summaries(), to: LobbyLib

  @doc section: :lobby
  @spec stream_lobby_summaries(map) :: Enumerable.t(LobbySummary.t())
  defdelegate stream_lobby_summaries(filters), to: LobbyLib

  @doc section: :lobby
  @spec open_lobby(Teiserver.user_id(), Lobby.name()) :: {:ok, Lobby.id()} | {:error, String.t()}
  defdelegate open_lobby(host_id, name), to: LobbyLib

  @doc section: :lobby
  @spec cycle_lobby(Lobby.id()) :: :ok
  defdelegate cycle_lobby(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec close_lobby(Lobby.id()) :: :ok
  defdelegate close_lobby(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec can_add_client_to_lobby?(Teiserver.user_id(), Lobby.id()) :: boolean()
  defdelegate can_add_client_to_lobby?(user_id, lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec add_client_to_lobby(Teiserver.user_id(), Lobby.id()) :: :ok | {:error, String.t()}
  defdelegate add_client_to_lobby(user_id, lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec remove_client_from_lobby(Teiserver.user_id(), Lobby.id()) :: :ok | nil
  defdelegate remove_client_from_lobby(user_id, lobby_id), to: LobbyLib

  # Match
  @doc section: :match
  @spec start_match(Lobby.t()) :: Match.t()
  defdelegate start_match(lobby), to: MatchLib

  @doc section: :match
  @spec end_match(Match.id(), map()) :: Match.t()
  defdelegate end_match(match_id, outcome), to: MatchLib

  ### Communication
  # MatchMessage
  @doc section: :match_message
  @spec subscribe_to_match_messages(Match.id() | Match.t()) :: :ok
  defdelegate subscribe_to_match_messages(match_or_match_id), to: MatchMessageLib

  @doc section: :match_message
  @spec unsubscribe_from_match_messages(Match.id() | Match.t()) :: :ok
  defdelegate unsubscribe_from_match_messages(match_or_match_id), to: MatchMessageLib

  @doc section: :match_message
  @spec send_match_message(Teiserver.user_id(), Match.id(), String.t()) ::
          {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate send_match_message(sender_id, match_id, content), to: MatchMessageLib

  # Room and RoomMessage
  @doc section: :room_message
  @spec subscribe_to_room_messages(Room.id() | Room.t()) :: :ok
  defdelegate subscribe_to_room_messages(room_or_room_id), to: RoomMessageLib

  @doc section: :room_message
  @spec unsubscribe_from_room_messages(Room.id() | Room.t()) :: :ok
  defdelegate unsubscribe_from_room_messages(room_or_room_id), to: RoomMessageLib

  @doc section: :room_message
  @spec get_room_by_name_or_id(Room.name_or_id()) :: Room.t() | nil
  defdelegate get_room_by_name_or_id(room_name_or_id), to: RoomLib

  @doc section: :room_message
  @spec list_recent_room_messages(Room.id()) :: [RoomMessage.t()]
  defdelegate list_recent_room_messages(room_name_or_id), to: RoomMessageLib

  @doc section: :room_message
  @spec send_room_message(Teiserver.user_id(), Room.id(), String.t()) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate send_room_message(sender_id, room_id, content), to: RoomMessageLib

  # DirectMessage
  @doc section: :direct_message
  @spec send_direct_message(Teiserver.user_id(), Teiserver.user_id(), String.t()) ::
          {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate send_direct_message(from_id, to_id, content), to: DirectMessageLib

  @doc section: :direct_message
  @spec subscribe_to_user_messaging(User.id() | User.t()) :: :ok
  defdelegate subscribe_to_user_messaging(user_or_user_id), to: DirectMessageLib

  @doc section: :direct_message
  @spec unsubscribe_from_user_messaging(User.id() | User.t()) :: :ok
  defdelegate unsubscribe_from_user_messaging(user_or_user_id), to: DirectMessageLib
end
