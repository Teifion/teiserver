defmodule Teiserver.Connections.ClientLib do
  @moduledoc """
  Library of client related functions.
  """
  # use TeiserverMacros, :library
  alias Teiserver.Connections.Client
  alias Teiserver.Account.User

  @doc false
  @spec client_topic(User.id() | User.t() | Client.t()) :: String.t()
  def client_topic(%User{id: user_id}), do: "Teiserver.Connections.Client:#{user_id}"
  def client_topic(%Client{id: user_id}), do: "Teiserver.Connections.Client:#{user_id}"
  def client_topic(user_id), do: "Teiserver.Connections.Client:#{user_id}"

  @doc """
  Subscribes the process to client updates for this user
  """
  @spec subscribe_to_client(User.id() | User.t() | Client.t()) :: :ok
  def subscribe_to_client(client_or_client_id) do
    client_or_client_id
    |> client_topic()
    |> Teiserver.subscribe()
  end

  @doc """
  Unsubscribes the process to client updates for this user
  """
  @spec unsubscribe_from_client(User.id() | User.t() | Client.t()) :: :ok
  def unsubscribe_from_client(client_or_client_id) do
    client_or_client_id
    |> client_topic()
    |> Teiserver.unsubscribe()
  end

  @doc """
  Returns the list of client ids.

  ## Examples

      iex> list_client_ids()
      [123, ...]

  """
  @spec list_client_ids() :: [Teiserver.user_id()]
  def list_client_ids do
    Horde.Registry.select(Teiserver.ClientRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  @spec list_local_client_ids() :: [Teiserver.user_id()]
  def list_local_client_ids do
    Registry.select(Teiserver.LocalClientRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  @doc """
  Gets a single client from a user_id.

  Returns nil if the Client does not exist.

  ## Examples

      iex> get_client(123)
      %Client{}

      iex> get_client(456)
      nil

  """
  @spec get_client(Teiserver.user_id()) :: Client.t() | nil
  def get_client(user_id) do
    call_client(user_id, :get_client_state)
  end

  @doc """
  Given a list of ids, return a list of client states.

  Returns nil if the Client does not exist.

  ## Examples

      iex> get_client_list([123, 124])
      [%Client{}, %Client{}]

      iex> get_client_list([456])
      [nil]

  """
  @spec get_client_list([Teiserver.user_id()]) :: [Client.t() | nil]
  def get_client_list(user_ids) do
    user_ids
    |> Enum.uniq()
    |> Enum.map(fn user_id ->
      call_client(user_id, :get_client_state)
    end)
  end

  @doc """
  Updates a client with the new data (excluding lobby related details). If changes are made then it will also generate a `Teiserver.Connections.Client:{user_id}` pubsub message; if they are present in a lobby it will generate a similar message to `Teiserver.Game.Lobby:{lobby_id}`.

  Returns nil if the Client does not exist, :ok if the client does.

  ## Examples

      iex> update_client(123, %{afk?: false}, "some reason")
      :ok

      iex> update_client(456, %{afk?: false}, "some reason")
      nil

  """
  @spec update_client(Teiserver.user_id(), map, String.t()) :: :ok | nil
  def update_client(user_id, data, reason) do
    cast_client(user_id, {:update_client, data, reason})
  end

  @doc """
  Similar to `update_client/3`, in the ClientServer it will first validate the update is acceptable and then send it off to the LobbyServer allowing it to change the update as it sees fit. Depending on other factors the LobbyServer may call out to the lobby host for further input.

  If the LobbyServer accepts any changes it will contact the ClientServer accordingly.

  Returns nil if the Client does not exist, :ok if the client does.

  ## Examples

      iex> update_client_in_lobby(123, %{player_number: 123}, "some reason")
      :ok

      iex> update_client_in_lobby(456, %{player_number: 123}, "some reason")
      nil

  """
  @spec update_client_in_lobby(Teiserver.user_id(), map, String.t()) :: :ok | nil
  def update_client_in_lobby(user_id, data, reason) do
    cast_client(user_id, {:update_client_in_lobby, data, reason})
  end

  # Used by the LobbyServer to update the ClientServer if `update_client_in_lobby/4` is successful
  @doc false
  @spec do_update_client_in_lobby(Teiserver.user_id(), map, String.t()) :: :ok | nil
  def do_update_client_in_lobby(user_id, data, reason) do
    cast_client(user_id, {:do_update_client_in_lobby, data, reason})
  end

  @doc """
  Given a user_id, log them in. If the user already exists as a client then the existing
  client is returned.

  The optional `opts` argument is passed through to the ClientServer starting up.

  The calling process will be listed as a connection for the client
  the client will monitor it for the purposes of tracking if the
  given client is still connected.
  """
  @spec connect_user(Teiserver.user_id(), list()) :: Client.t() | nil
  def connect_user(user_id, opts \\ []) do
    if client_exists?(user_id) do
      cast_client(user_id, {:add_connection, self()})
      get_client(user_id)
    else
      client = Client.new(user_id)
      _pid = start_client_server(client, opts)
      cast_client(user_id, {:add_connection, self()})
      client
    end
  end

  @doc """
  Sends a `:disconnect` message to every connection for the client and then stops the ClientServer
  """
  @spec disconnect_user(Teiserver.user_id()) :: :ok
  def disconnect_user(user_id) do
    call_client(user_id, :get_connections)
    |> Enum.each(fn pid ->
      send(pid, :disconnect)
    end)

    :timer.sleep(1000)
    stop_client_server(user_id)
  end

  @doc """
  Sends the calling process a `:disconnect` message and informs the ClientServer it is
  an intentional disconnect. This means if it is the last connection for the client the ClientServer
  will stop itself rather than going into a disconnected state.
  """
  @spec disconnect_single_connection(Teiserver.user_id()) :: :ok
  def disconnect_single_connection(user_id) when is_binary(user_id) do
    disconnect_single_connection(user_id, self())
  end

  @doc """
  Same as `disconnect_single_connection/1` except you can define the pid which is disconnected
  """
  @spec disconnect_single_connection(Teiserver.user_id(), pid()) :: :ok
  def disconnect_single_connection(user_id, pid) when is_binary(user_id) do
    cast_client(user_id, {:purposeful_disconnect, pid})
    send(pid, :disconnect)
  end

  # Process stuff
  @doc false
  @spec start_client_server(Client.t(), list) :: pid()
  def start_client_server(%Client{} = client, opts) do
    {:ok, server_pid} =
      DynamicSupervisor.start_child(Teiserver.ClientSupervisor, {
        Teiserver.Connections.ClientServer,
        name: "client_#{client.id}",
        data: %{
          client: client,
          opts: opts
        }
      })

    server_pid
  end

  @doc false
  @spec client_exists?(Teiserver.user_id()) :: pid() | boolean
  def client_exists?(user_id) do
    case Horde.Registry.lookup(Teiserver.ClientRegistry, user_id) do
      [{_pid, _}] -> true
      _ -> false
    end
  end

  @doc false
  @spec get_client_pid(Teiserver.user_id()) :: pid() | nil
  def get_client_pid(user_id) do
    case Horde.Registry.lookup(Teiserver.ClientRegistry, user_id) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end

  @doc false
  @spec cast_client(Teiserver.user_id(), any) :: any | nil
  def cast_client(user_id, msg) do
    case get_client_pid(user_id) do
      nil ->
        nil

      pid ->
        GenServer.cast(pid, msg)
        :ok
    end
  end

  @doc false
  @spec call_client(Teiserver.user_id(), any) :: any | nil
  def call_client(user_id, message) when is_binary(user_id) do
    case get_client_pid(user_id) do
      nil ->
        nil

      pid ->
        try do
          GenServer.call(pid, message)

          # If the process has somehow died, we just return nil
        catch
          :exit, _ ->
            nil
        end
    end
  end

  @doc false
  @spec stop_client_server(Teiserver.user_id()) :: :ok | nil
  def stop_client_server(user_id) when is_binary(user_id) do
    case get_client_pid(user_id) do
      nil ->
        nil

      p ->
        Teiserver.broadcast(client_topic(user_id), %{
          event: :client_destroyed,
          user_id: user_id
        })

        DynamicSupervisor.terminate_child(Teiserver.ClientSupervisor, p)
        :ok
    end
  end
end
