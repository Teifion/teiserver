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
  Returns the list of client ids.

  ## Examples

      iex> list_client_ids()
      [123, ...]

  """
  @spec list_client_ids() :: [Teiserver.user_id()]
  def list_client_ids() do
    Registry.select(Teiserver.ClientRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  @doc """
  Gets a single client.

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
  Updates a client with the new data. If changes are made then it will also generate a `Teiserver.Connections.Client:{user_id}` pubsub message.

  Returns nil if the Client does not exist, :ok if the client does.

  ## Examples

      iex> update_client(123, %{player_number: 123})
      :ok

      iex> update_client(456, %{player_number: 123})
      nil

  """
  @spec update_client(Teiserver.user_id(), map) :: :ok | nil
  def update_client(user_id, data) do
    cast_client(user_id, {:update_client, data})
  end

  @doc """
  Given a user_id, log them in. If the user already exists as a client then the existing
  client is returned.

  The calling process will be listed as a connection for the client
  the client will monitor it for the purposes of tracking if the
  given client is still connected.
  """
  @spec connect_user(Teiserver.user_id()) :: Client.t()
  def connect_user(user_id) do
    if client_exists?(user_id) do
      cast_client(user_id, {:add_connection, self()})
      get_client(user_id)
    else
      client = Client.new(user_id)
      _pid = start_client_server(client)
      cast_client(user_id, {:add_connection, self()})
      client
    end
  end

  # Process stuff
  @doc false
  @spec start_client_server(Client.t()) :: pid()
  def start_client_server(%Client{} = client) do
    {:ok, server_pid} =
      DynamicSupervisor.start_child(Teiserver.ClientSupervisor, {
        Teiserver.Connections.ClientServer,
        name: "client_#{client.id}",
        data: %{
          client: client
        }
      })

    server_pid
  end

  @doc """
  Tells us if the client exists right now or not.
  """
  @spec client_exists?(Teiserver.user_id()) :: pid() | boolean
  def client_exists?(user_id) do
    case Registry.lookup(Teiserver.ClientRegistry, user_id) do
      [{_pid, _}] -> true
      _ -> false
    end
  end

  @doc false
  @spec get_client_pid(Teiserver.user_id()) :: pid() | nil
  def get_client_pid(user_id) do
    case Registry.lookup(Teiserver.ClientRegistry, user_id) do
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
  def call_client(user_id, message) when is_integer(user_id) do
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
  def stop_client_server(user_id) do
    case get_client_pid(user_id) do
      nil ->
        nil

      p ->
        DynamicSupervisor.terminate_child(Teiserver.ClientSupervisor, p)
        :ok
    end
  end
end
