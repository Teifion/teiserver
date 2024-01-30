defmodule Teiserver.Api do
  @moduledoc """
  A set of functions for a basic usage of Teiserver. The purpose is
  to allow you to start with importing only this module and then
  import others as your needs grow more complex.
  """

  alias Teiserver.{Account, Communication, Connections}

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
end
