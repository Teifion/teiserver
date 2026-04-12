defmodule Teiserver.Helpers.CacheHelper do
  @moduledoc """
  A set of functions to interact with the various caches in the system.
  """

  @doc """
  Invalidates the cache for this table/key on this node and all other nodes
  in the cluster.
  """
  @spec invalidate_cache(atom, any) :: :ok
  def invalidate_cache(table, key_or_keys) do
    key_or_keys
    |> List.wrap()
    |> Enum.each(fn key ->
      Cachex.del(table, key)
    end)

    Phoenix.PubSub.broadcast(
      Teiserver.PubSub,
      "cache_cluster",
      {:cache_cluster, :delete, Node.self(), table, key_or_keys}
    )
  end

  @spec add_cache(atom, list) :: map()
  def add_cache(name, opts \\ []) when is_atom(name) do
    %{
      id: name,
      start:
        {Cachex, :start_link,
         [
           name,
           opts
         ]}
    }
  end
end
