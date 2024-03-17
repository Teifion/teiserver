defmodule Teiserver.Game.LobbyServer do
  @moduledoc """
  A process representing the state of a lobby.
  In the normal usage of Teiserver you are not expected to interact with it directly.
  """
  use GenServer
  require Logger
  alias Teiserver.{Connections}
  alias Teiserver.Game.{Lobby, LobbyLib, LobbySummary}
  alias Teiserver.Connections.ClientLib
  alias Teiserver.Helpers.MapHelper

  @heartbeat_frequency_ms 5_000

  defmodule State do
    @moduledoc false
    defstruct [:lobby, :lobby_id, :host_id, :match_id, :lobby_topic, :match_topic, :update_id]
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

  def handle_call({:can_add_client?, user_id}, _from, state) do
    {:reply, can_add_client?(user_id, state), state}
  end

  def handle_call({:client_update_request, %{id: _user_id} = changes}, _from, state) do
    {:reply, changes, state}
  end

  # Attempts to add a client to the lobby
  def handle_call({:add_client, user_id}, _from, state) do
    case can_add_client?(user_id, state) do
      {false, reason} ->
        {:reply, {:error, reason}, state}

      {true, _} ->
        new_state = do_add_client(user_id, state)
        {:reply, :ok, new_state}
    end
  end

  def handle_call(msg, _from, state) do
    raise "err: #{inspect(msg)}"
    {:reply, nil, state}
  end

  @impl true
  def handle_cast({:update_lobby, changes}, state) do
    new_state = update_lobby(state, changes)
    {:noreply, new_state}
  end

  def handle_cast({:remove_client, user_id}, state) do
    if Enum.member?(state.lobby.members, user_id) do
      new_state = do_remove_client(user_id, state)
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:cycle_lobby, match_id}, state) do
    match_topic = nil
    # match_topic = Game.match_topic(match.id)

    new_state =
      update_lobby(state, %{
        match_id: match_id,
        match_ongoing?: false,
        match_type: nil
      })

    {:noreply, %{new_state | match_id: match_id, match_topic: match_topic}}
  end

  def handle_cast(:lobby_start_match, state) do
    new_state =
      update_lobby(state, %{
        match_ongoing?: true
      })

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
    new_state = update_lobby(state, %{host_data: nil})
    {:noreply, new_state}
  end

  def handle_info(%{topic: "Teiserver.Connections.Client" <> _, event: :client_destroyed}, state) do
    LobbyLib.stop_lobby_server(state.lobby_id)
    {:noreply, state}
  end

  def handle_info(
        %{topic: "Teiserver.Connections.Client" <> _, event: :client_updated, user_id: user_id} = msg,
        state
      ) do
    lobby = state.lobby

    # Are they now a player?
    changes =
      cond do
        not Map.has_key?(msg.changes, :player?) ->
          %{}

        msg.changes.player? && Enum.member?(lobby.spectators, user_id) ->
          %{
            spectators: List.delete(lobby.spectators, user_id),
            players: [user_id | lobby.players]
          }

        not msg.changes.player? && Enum.member?(lobby.players, user_id) ->
          %{
            players: List.delete(lobby.players, user_id),
            spectators: [user_id | lobby.players]
          }

        true ->
          %{}
      end

    if changes == %{} do
      {:noreply, state}
    else
      new_state = update_lobby(state, changes)

      {:noreply, new_state}
    end
  end

  def handle_info(%{topic: "Teiserver." <> _}, state) do
    {:noreply, state}
  end

  @doc false
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  @spec can_add_client?(Teiserver.user_id(), State.t()) :: {boolean(), String.t() | nil}
  defp can_add_client?(user_id, %{lobby: lobby} = _state) do
    cond do
      Enum.member?(lobby.members, user_id) ->
        {false, "Existing member"}

      true ->
        client = Connections.get_client(user_id)

        cond do
          client == nil ->
            {false, "Client is not connected"}

          client.connected? == false ->
            {false, "Client is disconnected"}

          client.lobby_id != nil ->
            {:error, "Already in a lobby"}

          true ->
            {true, nil}
        end
    end
  end

  @spec update_lobby(State.t(), map()) :: State.t()
  def update_lobby(state, changes) do
    new_lobby = state.lobby
      |> struct(changes)
      |> apply_calculated_changes

    do_update_lobby(state, new_lobby)
  end

  @spec do_update_lobby(State.t(), Lobby.t()) :: State.t()
  defp do_update_lobby(%State{} = state, %Lobby{} = new_lobby) do
    diffs = MapHelper.map_diffs(state.lobby, new_lobby)

    if diffs == %{} do
      # Nothing changed, we don't do anything
      state
    else
      new_update_id = state.lobby.update_id + 1
      new_lobby = struct(new_lobby, %{update_id: new_update_id})

      diffs = Map.put(diffs, :update_id, new_update_id)

      Teiserver.broadcast(
        state.lobby_topic,
        %{
          event: :lobby_updated,
          update_id: new_update_id,
          lobby_id: state.lobby_id,
          changes: diffs
        }
      )

      %{state | lobby: new_lobby}
    end
  end

  @spec apply_calculated_changes(Lobby.t()) :: Lobby.t()
  defp apply_calculated_changes(lobby_state) do
    changes = %{
      passworded?: (lobby_state.password != nil && lobby_state.password != "")
    }

    struct(lobby_state, changes)
  end

  @spec do_add_client(Teiserver.user_id(), State.t()) :: State.t()
  defp do_add_client(user_id, state) do
    ClientLib.update_client_full(user_id, %{
      lobby_id: state.lobby_id,
      ready?: false,
      player?: false,
      player_number: nil,
      team_number: nil,
      team_colour: nil,
      sync: nil,
      lobby_host?: false
    }, "joined_lobby")

    client = ClientLib.get_client(user_id)

    Teiserver.broadcast(
      state.lobby_topic,
      %{
        event: :lobby_user_joined,
        lobby_id: state.lobby_id,
        client: client
      }
    )

    Connections.subscribe_to_client(user_id)

    update_lobby(state, %{
      members: [user_id | state.lobby.members],
      spectators: [user_id | state.lobby.spectators]
    })
  end

  @spec do_remove_client(Teiserver.user_id(), State.t()) :: State.t()
  defp do_remove_client(user_id, state) do
    Connections.unsubscribe_from_client(user_id)

    ClientLib.update_client_full(user_id, %{
      lobby_id: nil,
      ready?: false,
      player?: false,
      player_number: nil,
      team_number: nil,
      team_colour: nil,
      sync: nil,
      lobby_host?: false
    }, "left_lobby")

    Teiserver.broadcast(
      state.lobby_topic,
      %{
        event: :lobby_user_left,
        lobby_id: state.lobby_id,
        user_id: user_id
      }
    )

    update_lobby(state, %{
      members: List.delete(state.lobby.members, user_id),
      spectators: List.delete(state.lobby.spectators, user_id),
      players: List.delete(state.lobby.players, user_id)
    })
  end

  @impl true
  @spec init(map) :: {:ok, map}
  def init(%{lobby: %Lobby{id: id} = lobby}) do
    # Logger.metadata(request_id: "LobbyServer##{id}")
    :timer.send_interval(@heartbeat_frequency_ms, :heartbeat)

    # Update the queue pids cache to point to this process
    Horde.Registry.register(
      Teiserver.LobbyRegistry,
      id,
      id
    )

    Registry.register(
      Teiserver.LocalLobbyRegistry,
      id,
      id
    )

    topic = Connections.client_topic(lobby.host_id)
    Teiserver.subscribe(topic)

    {:ok,
     %State{
       lobby_id: id,
       host_id: lobby.host_id,
       match_id: nil,
       lobby: lobby,
       lobby_topic: LobbyLib.lobby_topic(id),
       match_topic: nil
     }}
  end
end
