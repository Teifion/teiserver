defmodule Teiserver.Api do
  @moduledoc """
  A set of functions for a basic usage of Teiserver. The purpose is
  to allow you to start with importing only this module and then
  import others as your needs grow more complex.
  """

  alias Teiserver.{Account, Communication, Connections}
  alias Account.UserLib

  alias Communication.{
    Room,
    RoomLib,
    RoomMessage,
    RoomMessageLib,
    DirectMessage,
    DirectMessageLib
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
  @spec connect_user(Teiserver.user_id()) :: :ok
  def connect_user(user_id) when is_integer(user_id) do
    Connections.connect_user(user_id)
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
  @spec register_user(String.t(), String.t(), String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(name, email, password) do
    Teiserver.Account.create_user(%{
      "name" => name,
      "password" => password,
      "email" => email
    })
  end

  # Account
  @spec get_user_by_id(Teiserver.user_id()) :: User.t() | nil
  defdelegate get_user_by_id(user_id), to: UserLib

  @spec get_user_by_name(String.t()) :: User.t() | nil
  defdelegate get_user_by_name(name), to: UserLib

  # Game


  # Communication
  @spec subscribe_to_room(Room.id() | Room.t() | String.t()) :: :ok
  defdelegate subscribe_to_room(room_id_or_name), to: RoomLib

  @spec unsubscribe_from_room(Room.id() | Room.t() | String.t()) :: :ok
  defdelegate unsubscribe_from_room(room_id_or_name), to: RoomLib

  @spec get_room_by_name_or_id(Room.name_or_id()) :: Room.t() | nil
  defdelegate get_room_by_name_or_id(room_name_or_id), to: RoomLib

  @spec list_recent_room_messages(Room.id()) :: [RoomMessage.t()]
  defdelegate list_recent_room_messages(room_name_or_id), to: RoomMessageLib

  @spec send_room_message(Teiserver.user_id(), Room.id(), String.t()) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate send_room_message(sender_id, room_id, content), to: RoomMessageLib

  @spec send_direct_message(Teiserver.user_id(), Teiserver.user_id(), String.t()) ::
          {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  defdelegate send_direct_message(from_id, to_id, content), to: DirectMessageLib
end
