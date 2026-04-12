defmodule Teiserver.System.CacheClusterServer do
  @moduledoc """
  Allows us to track cache invalidation across a cluster.
  """
  use GenServer
  alias Phoenix.PubSub

  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl true
  def handle_info({:cache_cluster, :delete, from_node, table, key_or_keys}, state) do
    if from_node != Node.self() do
      key_or_keys
      |> List.wrap()
      |> Enum.each(fn key ->
        Cachex.del(table, key)
      end)
    end

    {:noreply, state}
  end

  @impl true
  @spec init(any) :: {:ok, %{}}
  def init(_) do
    :ok = PubSub.subscribe(Teiserver.PubSub, "cache_cluster")
    {:ok, %{}}
  end
end
