defmodule Teiserver.Connections.ClientServer do
  @moduledoc """
  A process representing the state of a client. In the normal usage of Teiserver
  you are not expected to interact with it directly.
  """
  use GenServer
  require Logger
  alias Teiserver.Connections.Client

  defmodule State do
    @moduledoc false
    defstruct [:client, :user_id, :connections, :update_id]
  end

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
      {:noreply, %State{state | connections: new_connections, client: new_client}}
    end
  end

  def handle_cast({:update_client, partial_client}, state) do
    new_client = struct(state.client, partial_client)
    new_state = update_client(state, new_client)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:heartbeat, state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _normal}, state) do
    new_connections =
      if Enum.member?(state.connections, pid) do
        List.delete(state.connections, pid)
      else
        Logger.error("#{__MODULE__} got :DOWN message but did not have it as a connection")
        state.connections
      end

    if Enum.empty?(new_connections) do
      new_client = %{state.client | connected?: false}

      {:noreply, %State{state | connections: new_connections, client: new_client}}
    else
      {:noreply, %State{state | connections: new_connections}}
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
        "Teiserver.ClientServer:#{state.user_id}",
        %{
          event: :client_updated,
          update_id: new_update_id,
          client: new_client
        }
      )

      %{state | client: new_client, update_id: new_update_id}
    end
  end

  @impl true
  @spec init(map) :: {:ok, map}
  def init(%{client: %Client{id: id} = client}) do
    # Logger.metadata(request_id: "ClientServer##{id}")
    :timer.send_interval(6_000, :heartbeat)

    # Update the queue pids cache to point to this process
    Registry.register(
      Teiserver.ClientRegistry,
      id,
      id
    )

    {:ok,
     %State{
       client: client,
       connections: [],
       user_id: id,
       update_id: 0
     }}
  end
end
