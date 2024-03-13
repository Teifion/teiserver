defmodule Teiserver.Connections.ClientServer do
  @moduledoc """
  A process representing the state of a client. In the normal usage of Teiserver
  you are not expected to interact with it directly.
  """
  use GenServer
  require Logger
  alias Teiserver.Game.LobbyLib
  alias Teiserver.Connections.{Client, ClientLib}

  @heartbeat_frequency_ms 5_000

  # The amount of time after the last disconnect at which we will destroy the ClientServer process
  @client_destroy_timeout_seconds Application.compile_env(
                                    :teiserver,
                                    :client_destroy_timeout_seconds,
                                    300
                                  )

  defmodule State do
    @moduledoc false
    defstruct [:client, :user_id, :connections, :update_id, :client_topic, :lobby_topic]
  end

  @standard_data_keys ~w(connected? last_disconnected in_game? afk? party_id)a
  @lobby_data_keys ~w(ready? player? player_number team_number team_colour sync lobby_host?)a

  @impl true
  def handle_call(:get_client_state, _from, state) do
    {:reply, state.client, state}
  end

  @impl true
  def handle_cast({:add_connection, conn_pid}, state) when is_pid(conn_pid) do
    Process.monitor(conn_pid)
    new_connections = [conn_pid | state.connections]

    if state.client.connected? do
      {:noreply, %State{state | connections: new_connections}}
    else
      new_client = %{state.client | connected?: true}

      Teiserver.broadcast(state.client_topic, %{
        event: :client_connected,
        client: new_client
      })

      {:noreply, %State{state | connections: new_connections, client: new_client}}
    end
  end

  def handle_cast({:update_client, partial_client}, state) do
    partial_client = Map.take(partial_client, @standard_data_keys)

    if partial_client != %{} do
      new_client = struct(state.client, partial_client)
      new_state = update_client(state, new_client)
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:update_client_in_lobby, partial_client}, state) do
    partial_client =
      partial_client
      |> Map.take(@lobby_data_keys)
      |> Map.put(:id, state.user_id)
      |> LobbyLib.client_update_request(state.client.lobby_id)

    if partial_client != %{} do
      new_client = struct(state.client, partial_client)
      new_state = update_client(state, new_client)
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:update_client_full, partial_client}, state) do
    new_client = struct(state.client, partial_client)
    new_state = update_client(state, new_client)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:heartbeat, %State{client: %{connected?: false}} = state) do
    seconds_since_disconnect = Timex.diff(Timex.now(), state.client.last_disconnected, :second)

    if seconds_since_disconnect > @client_destroy_timeout_seconds do
      ClientLib.stop_client_server(state.user_id)
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_info(:heartbeat, %State{} = state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _normal}, state) do
    new_state = lose_connection(pid, state)
    {:noreply, new_state}
  end

  @spec lose_connection(pid(), State.t()) :: State.t()
  defp lose_connection(pid, state) do
    if Enum.member?(state.connections, pid) do
      new_connections = List.delete(state.connections, pid)

      if Enum.empty?(new_connections) do
        new_client = %{state.client | connected?: false, last_disconnected: Timex.now()}

        Teiserver.broadcast(state.client_topic, %{
          event: :client_disconnected,
          client: new_client
        })

        %State{state | connections: new_connections, client: new_client}
      else
        %State{state | connections: new_connections}
      end
    else
      Logger.error("#{__MODULE__} got :DOWN message but did not have it as a connection")
      state
    end
  end

  @doc false
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  @spec update_client(State.t(), Client.t()) :: State.t()
  defp update_client(%State{} = state, %Client{} = new_client) do
    if new_client == state.client do
      # Nothing changed, we don't do anything
      state
    else
      new_update_id = state.update_id + 1

      Teiserver.broadcast(
        state.client_topic,
        %{
          event: :client_updated,
          update_id: new_update_id,
          client: new_client
        }
      )

      if state.lobby_topic do
        Teiserver.broadcast(
          state.lobby_topic,
          %{
            event: :lobby_client_change,
            update_id: new_update_id,
            client: new_client
          }
        )
      end

      new_state = cond do
        state.client.lobby_id == nil && new_client.lobby_id != nil ->
          added_to_lobby(new_client.lobby_id, state)

        state.client.lobby_id != nil && new_client.lobby_id == nil ->
          removed_from_lobby(state.client.lobby_id, state)

        true ->
          state
      end

      %{new_state | client: new_client, update_id: new_update_id}
    end
  end

  @spec added_to_lobby(Teiserver.lobby_id(), State.t()) :: State.t()
  defp added_to_lobby(lobby_id, state) do
    Teiserver.broadcast(
      state.client_topic,
      %{
        event: :joined_lobby,
        user_id: state.user_id,
        lobby_id: lobby_id
      }
    )

    # LobbyLib.subscribe_to_lobby(lobby_id)
    %{state | lobby_topic: LobbyLib.lobby_topic(lobby_id)}
  end

  @spec removed_from_lobby(Teiserver.lobby_id(), State.t()) :: State.t()
  defp removed_from_lobby(lobby_id, state) do
    Teiserver.broadcast(
      state.client_topic,
      %{
        event: :left_lobby,
        user_id: state.user_id,
        lobby_id: lobby_id
      }
    )

    # LobbyLib.unsubscribe(lobby_id)
    %{state | lobby_topic: nil}
  end

  @impl true
  @spec init(map) :: {:ok, map}
  def init(%{client: %Client{id: id} = client}) do
    # Logger.metadata(request_id: "ClientServer##{id}")
    :timer.send_interval(@heartbeat_frequency_ms, :heartbeat)

    # Update the queue pids cache to point to this process
    Registry.register(
      Teiserver.LocalClientRegistry,
      id,
      id
    )

    Horde.Registry.register(
      Teiserver.ClientRegistry,
      id,
      id
    )

    {:ok,
     %State{
       client: client,
       connections: [],
       user_id: id,
       client_topic: ClientLib.client_topic(id),
       lobby_topic: nil,
       update_id: 0
     }}
  end
end
