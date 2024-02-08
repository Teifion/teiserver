defmodule Teiserver.Game.LobbyServer do
  @moduledoc """
  A process representing the state of a lobby.
  In the normal usage of Teiserver you are not expected to interact with it directly.
  """
  use GenServer
  require Logger
  alias Teiserver.Connections
  alias Teiserver.Game.{Lobby, LobbyLib, LobbySummary}

  @heartbeat_frequency_ms 5_000

  defmodule State do
    @moduledoc false
    defstruct [:lobby, :lobby_id, :host_id, :topic, :update_id]
  end

  @impl true
  def handle_call(:get_lobby_state, _from, state) do
    {:reply, state.lobby, state}
  end

  def handle_call(:get_lobby_summary, _from, state) do
    {:reply, LobbySummary.new(state.lobby), state}
  end

  def handle_call({:get_lobby_attribute, key}, _from, state) do
    {:reply, Map.get(state.lobby, key), state}
  end

  @impl true
  def handle_cast({:update_lobby, partial_lobby}, state) do
    new_lobby = struct(state.lobby, partial_lobby)
    new_state = update_lobby(state, new_lobby)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:heartbeat, %State{} = state) do
    {:noreply, state}
  end

  # Currently do nothing on return, we expect the client process to give us host_data
  # which will then communicate via lobby_update that we're connected again
  def handle_info(%{topic: "Teiserver.Connections.Client" <> _, event: :client_connected}, state) do
    {:noreply, state}
  end

  # Set the host_data to nil
  def handle_info(
        %{topic: "Teiserver.Connections.Client" <> _, event: :client_disconnected},
        state
      ) do
    new_lobby = struct(state.lobby, %{host_data: nil})
    new_state = update_lobby(state, new_lobby)
    {:noreply, new_state}
  end

  def handle_info(%{topic: "Teiserver.Connections.Client" <> _, event: :client_destroyed}, state) do
    LobbyLib.stop_lobby_server(state.lobby_id)
    {:noreply, state}
  end

  def handle_info(%{topic: "Teiserver." <> _}, state) do
    {:noreply, state}
  end

  @doc false
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  @spec update_lobby(State.t(), Lobby.t()) :: State.t()
  defp update_lobby(%State{} = state, %Lobby{} = new_lobby) do
    if new_lobby == state.lobby do
      # Nothing changed, we don't do anything
      state
    else
      new_update_id = state.update_id + 1

      Teiserver.broadcast(
        state.topic,
        %{
          event: :lobby_updated,
          update_id: new_update_id,
          lobby: new_lobby
        }
      )

      %{state | lobby: new_lobby, update_id: new_update_id}
    end
  end

  @impl true
  @spec init(map) :: {:ok, map}
  def init(%{lobby: %Lobby{id: id} = lobby}) do
    # Logger.metadata(request_id: "LobbyServer##{id}")
    :timer.send_interval(@heartbeat_frequency_ms, :heartbeat)

    # Update the queue pids cache to point to this process
    Registry.register(
      Teiserver.LobbyRegistry,
      id,
      id
    )

    topic = Connections.client_topic(lobby.host_id)
    Teiserver.subscribe(topic)

    {:ok,
     %State{
       lobby_id: id,
       host_id: lobby.host_id,
       lobby: lobby,
       topic: LobbyLib.lobby_topic(id),
       update_id: 0
     }}
  end
end
