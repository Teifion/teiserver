defmodule Teiserver.System.ClusterManagerSupervisor do
  @moduledoc """
  The dynamic supervisor for the ClusterManager
  """
  use DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_restarts: 10000,
      max_seconds: 1
    )
  end

  @spec start_cluster_manager_supervisor_children() ::
          :ok | {:error, :start_failure}
  def start_cluster_manager_supervisor_children() do
    # Start up the Cluster Manager
    result = start_cluster_manager()

    children_count =
      DynamicSupervisor.count_children(Teiserver.System.ClusterManagerSupervisor)

    Logger.info(
      "#{__MODULE__} Supervisor startup completed. Child data:#{inspect(children_count)}"
    )

    result
  end

  @spec start_cluster_manager() :: :ok | {:error, :start_failure}
  defp start_cluster_manager() do
    case DynamicSupervisor.start_child(
           __MODULE__,
           {Teiserver.System.ClusterManager, []}
         ) do
      {:ok, _pid} ->
        :ok

      {:ok, _pid, _info} ->
        :ok

      {:error, {:already_started, _pid}} ->
        :ok

      error ->
        Logger.error("Failed to start Cluster Manager, error:#{inspect(error)}.")
        {:error, :start_failure}
    end
  end
end
