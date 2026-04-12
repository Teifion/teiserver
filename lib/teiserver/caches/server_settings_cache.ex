defmodule Teiserver.Caches.ServerSettingCache do
  @moduledoc """
  Cache and setup for communication stuff
  """

  use Supervisor
  import Teiserver.Helpers.CacheHelper, only: [add_cache: 2]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      add_cache(:ts_server_setting_type_store, ttl: :timer.minutes(5)),
      add_cache(:ts_server_setting_cache, ttl: :timer.minutes(1))
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
