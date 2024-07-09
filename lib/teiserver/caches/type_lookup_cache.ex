defmodule Teiserver.Caches.TypeLookupCache do
  @moduledoc """
  Cache for tracking type_ids of various fields to prevent repeated DB lookups
  """

  use Supervisor
  import Teiserver.Helpers.CacheHelper, only: [add_cache: 2]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      add_cache(:ts_match_type_lookup, ttl: :timer.minutes(5)),
      add_cache(:ts_match_setting_type_lookup, ttl: :timer.minutes(5)),
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
