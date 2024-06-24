defmodule Teiserver.System.ClusterMemberServer do
  @moduledoc """
  The cluster manager for handling adding nodes to a cluster.

  You can disable this process with the config:
  ```
  config :teiserver,
    teiserver_clustering: false
  ```
  """
  use GenServer
  require Logger
  alias Teiserver.System.{ClusterMember, ClusterMemberLib}

  @startup_delay 500

  # GenServer behaviour
  def start_link(params, _opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      params,
      name: __MODULE__
    )
  end

  @impl GenServer
  def init(_params) do
    # Make sure we are told about any nodes joining or leaving the cluster
    :net_kernel.monitor_nodes(true)
    Process.send_after(self(), {:startup, 1}, @startup_delay)

    {:ok, :pending}
  end

  @impl GenServer
  def handle_call(other, from, state) do
    Logger.warning(
      "unhandled call to ClusterMemberServer: #{inspect(other)}. From: #{inspect(from)}"
    )

    {:reply, :not_implemented, state}
  end

  @impl GenServer
  def handle_cast(other, state) do
    Logger.warning("unhandled cast to ClusterMemberServer: #{inspect(other)}.")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:startup, start_count}, _state) do
    if repo_ready?() do
      host_name = Node.self() |> Atom.to_string()

      # If we are running one node or something goes wrong the database will have
      # a vestigial row for this node, in that case we can just leave it as is
      case ClusterMemberLib.get_cluster_member(nil, where: [host: host_name]) do
        nil ->
          ClusterMemberLib.create_cluster_member(%{
            host: host_name
          })

        _existing ->
          # Do nothing
          :ok
      end

      # Attempt to join the cluster, if there are any other Nodes "out there"....
      case attempt_to_join_cluster() do
        false ->
          :ok

        true ->
          Application.get_env(:teiserver, :teiserver_clustering_post_join_functions, [])
          |> Enum.each(fn post_join_function ->
            apply(post_join_function, [])
          end)
      end

      {:noreply, :running}
    else
      Process.send_after(self(), {:startup, start_count + 1}, @startup_delay * start_count)
      {:noreply, :pending}
    end
  end

  def handle_info({:nodeup, node_name}, state) do
    Logger.info("nodeup message to ClusterMemberServer: #{inspect(node_name)}.")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:nodedown, node_name}, state) do
    node_to_remove = Atom.to_string(node_name)
    ClusterMemberLib.delete_cluster_member(node_to_remove)
    Logger.warning("nodedown message to ClusterMemberServer: #{inspect(node_name)}.")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(other, state) do
    Logger.warning("unhandled message to ClusterMemberServer: #{inspect(other)}.")
    {:noreply, state}
  end

  @spec attempt_to_join_cluster() :: boolean()
  defp attempt_to_join_cluster() do
    host_name = Node.self() |> Atom.to_string()

    case ClusterMemberLib.list_cluster_members(where: [host_not: host_name], limit: :infinity) do
      [] ->
        Logger.info("Empty cluster, no join has taken place: #{inspect(Node.self())}")
        false

      members ->
        members
        |> Enum.reduce_while(false, &attempt_connection/2)
        |> case do
          true ->
            Logger.info("Node successfully joined the cluster: #{inspect(Node.self())}")
            true

          false ->
            names =
              members
              |> Enum.map_join(", ", fn m -> m.host end)

            Logger.error(
              "Node #{inspect(Node.self())} failed to successfully join the cluster, tried: #{names}"
            )

            false
        end
    end
  end

  @spec attempt_connection(ClusterMember.t(), boolean()) :: {:halt | :cont, boolean()}
  defp attempt_connection(%ClusterMember{host: host}, acc) do
    case Node.connect(String.to_atom(host)) do
      true ->
        {:halt, true}

      false ->
        {:cont, acc}

      :ignored ->
        {:cont, acc}
    end
  end

  @spec repo_ready?() :: boolean
  defp repo_ready?() do
    case Ecto.Repo.all_running() do
      [] -> false
      _ready -> true
    end
  end
end
