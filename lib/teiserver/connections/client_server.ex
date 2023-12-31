defmodule Teiserver.Account.ClientServer do
  @moduledoc """
  A process representing the state of a client.
  """
  use GenServer
  require Logger
  alias Phoenix.PubSub

  defmodule State do
    @moduledoc false

    defstruct [:client, :user_id]
  end

  @impl true
  def handle_call(:get_client_state, _from, state) do
    {:reply, state.client, state}
  end

  @impl true
  def handle_cast({:update_values, partial_client}, state) do
    new_client = Map.merge(state.client, partial_client)

    PubSub.broadcast(
      Teiserver.PubSub,
      "teiserver_client_messages:#{state.user_id}",
      %{
        channel: "teiserver_client_messages:#{state.user_id}",
        event: :client_updated,
        user_id: state.user_id,
        client: new_client
      }
    )

    if state.client.lobby_id do
      PubSub.broadcast(
        Teiserver.PubSub,
        "teiserver_lobby_updates:#{state.client.lobby_id}",
        %{
          channel: "teiserver_lobby_updates",
          event: :updated_client_battlestatus,
          lobby_id: state.client.lobby_id,
          user_id: state.user_id,
          client: partial_client
        }
      )
    end

    {:noreply, %{state | client: new_client}}
  end

  @impl true
  def handle_info(:heartbeat, %{client: _client} = state) do
    # cond do
    #   client_state.tcp_pid == nil ->
    #     DynamicSupervisor.terminate_child(Teiserver.ClientSupervisor, self())

    #   Process.alive?(client_state.tcp_pid) == false ->
    #     DynamicSupervisor.terminate_child(Teiserver.ClientSupervisor, self())

    #   true ->
    #     :ok
    # end

    {:noreply, state}
  end

  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  @impl true
  @spec init(map) :: {:ok, map}
  def init(%{client: %{id: id}} = state) do
    # Logger.metadata(request_id: "ClientServer##{id}")
    :timer.send_interval(6_000, :heartbeat)

    # Update the queue pids cache to point to this process
    Registry.register(
      Teiserver.ClientRegistry,
      id,
      id
    )

    {:ok,
     Map.merge(state, %{
       user_id: id
     })}
  end
end
