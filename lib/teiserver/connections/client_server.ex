defmodule Teiserver.Connections.ClientServer do
  @moduledoc """
  A process representing the state of a client. In the normal usage of Teiserver
  you are not expected to interact with it directly.
  """
  use GenServer
  require Logger
  alias Teiserver.Game.LobbyLib
  alias Teiserver.Connections.{Client, ClientLib}
  alias Teiserver.Helpers.MapHelper

  @heartbeat_frequency_ms 5_000

  # The amount of time after the last disconnect at which we will destroy the ClientServer process
  @client_destroy_timeout_seconds Application.compile_env(
                                    :teiserver,
                                    :client_destroy_timeout_seconds,
                                    300
                                  )

  defmodule State do
    @moduledoc false
    defstruct [:client, :user_id, :connections, :client_topic, :lobby_topic]
  end

  @impl true
  def handle_call(:get_client_state, _from, state) do
    {:reply, state.client, state}
  end

  def handle_call(:get_connections, _from, state) do
    {:reply, state.connections, state}
  end

  @impl true
  def handle_cast({:add_connection, conn_pid}, state) when is_pid(conn_pid) do
    Process.monitor(conn_pid)
    new_connections = Enum.uniq([conn_pid | state.connections])

    if state.client.connected? do
      :telemetry.execute(
        [:teiserver, :client, :connect],
        %{type: :added_connection},
        %{user_id: state.user_id}
      )

      {:noreply, %State{state | connections: new_connections}}
    else
      :telemetry.execute(
        [:teiserver, :client, :connect],
        %{type: :new_connection},
        %{user_id: state.user_id}
      )

      new_client = %{state.client | connected?: true}

      Teiserver.broadcast(state.client_topic, %{
        event: :client_connected,
        user_id: state.user_id,
        client: new_client
      })

      {:noreply, %State{state | connections: new_connections, client: new_client}}
    end
  end

  def handle_cast({:update_client, partial_client, reason}, state) do
    if Enum.empty?(partial_client) do
      {:noreply, state}
    else
      :telemetry.execute(
        [:teiserver, :client, :updated],
        %{change_count: Enum.count(partial_client)},
        %{user_id: state.user_id}
      )

      new_client = struct(state.client, partial_client)
      new_state = update_client(state, new_client, reason)
      {:noreply, new_state}
    end
  end

  def handle_cast({:update_client_in_lobby, partial_client, reason}, state) do
    if Enum.empty?(partial_client) or state.client.lobby_id == nil do
      {:noreply, state}
    else
      new_client = struct(state.client, partial_client)
      diffs = MapHelper.map_diffs(state.client, new_client)

      if not Enum.empty?(diffs) do
        LobbyLib.client_update_request(state.client.lobby_id, new_client, diffs, reason)
      end

      {:noreply, state}
    end
  end

  def handle_cast({:do_update_client_in_lobby, new_client, reason}, state) do
    :telemetry.execute(
      [:teiserver, :client, :updated_in_lobby],
      %{},
      %{user_id: state.user_id}
    )

    new_state = update_client(state, new_client, reason)
    {:noreply, new_state}
  end

  # Unlike with a normal :DOWN message, this is one where the person purposefully disconnects
  # and thus we don't want to keep the client alive
  def handle_cast({:purposeful_disconnect, pid}, state) do
    new_state = lose_connection(pid, state)

    :telemetry.execute(
      [:teiserver, :client, :disconnect],
      %{reason: :purposeful},
      %{user_id: state.user_id}
    )

    if new_state.client.connected? do
      {:noreply, new_state}
    else
      ClientLib.stop_client_server(state.user_id)
      {:noreply, new_state}
    end
  end

  @impl true
  def handle_info(:heartbeat, %State{client: %{connected?: false}} = state) do
    seconds_since_disconnect = DateTime.diff(DateTime.utc_now(), state.client.last_disconnected, :second)

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
    :telemetry.execute(
      [:teiserver, :client, :disconnect],
      %{reason: :down_message},
      %{user_id: state.user_id}
    )

    new_state = lose_connection(pid, state)
    {:noreply, new_state}
  end

  @spec lose_connection(pid(), State.t()) :: State.t()
  defp lose_connection(pid, state) do
    if Enum.member?(state.connections, pid) do
      new_connections = List.delete(state.connections, pid)

      if Enum.empty?(new_connections) do
        new_client = %{state.client | connected?: false, last_disconnected: DateTime.utc_now()}

        Teiserver.broadcast(state.client_topic, %{
          event: :client_disconnected,
          user_id: state.user_id,
          client: new_client
        })

        %State{state | connections: new_connections, client: new_client}
      else
        %State{state | connections: new_connections}
      end
    else
      state
    end
  end

  @doc false
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  @spec update_client(State.t(), Client.t(), String.t()) :: State.t()
  defp update_client(%State{} = state, %Client{} = new_client, reason) do
    diffs = MapHelper.map_diffs(state.client, new_client)

    if Enum.empty?(diffs) do
      # Nothing changed, we don't do anything
      state
    else
      # Client has changed, we need to increment the update_id
      new_update_id = state.client.update_id + 1
      new_client = struct(new_client, %{update_id: new_update_id})

      diffs = Map.put(diffs, :update_id, new_update_id)

      Teiserver.broadcast(
        state.client_topic,
        %{
          event: :client_updated,
          changes: diffs,
          user_id: state.user_id,
          reason: reason
        }
      )

      if state.lobby_topic do
        Teiserver.broadcast(
          state.lobby_topic,
          %{
            event: :lobby_client_change,
            changes: diffs,
            user_id: state.user_id,
            reason: reason
          }
        )
      end

      new_state =
        cond do
          state.client.lobby_id == nil && new_client.lobby_id != nil ->
            added_to_lobby(new_client.lobby_id, state)

          state.client.lobby_id != nil && new_client.lobby_id == nil ->
            removed_from_lobby(state.client.lobby_id, state)

          true ->
            state
        end

      %{new_state | client: new_client}
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

    %{state | lobby_topic: nil}
  end

  @impl true
  @spec init(map) :: {:ok, map}
  def init(%{client: %Client{id: id} = client, opts: opts}) do
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

    # Handle opts
    client =
      struct(client, %{
        bot?: opts[:bot?] || false
      })

    # After being created a client will typically have
    # a connection be added, it is possible in some cases
    # for a timing issue to happen where the connection will not correctly
    # add itself and thus the client will count as disconnected but
    # with no last_disconnect value
    # Putting in this 50ms sleep solves the issue
    :timer.sleep(50)

    {:ok,
     %State{
       client: client,
       connections: [],
       user_id: id,
       client_topic: ClientLib.client_topic(id),
       lobby_topic: nil
     }}
  end
end
