defmodule Teiserver.Caches.LoginCountCache do
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
      add_cache(:ts_login_count_ip, ttl: :timer.minutes(5)),
      add_cache(:ts_login_count_user, ttl: :timer.minutes(5))
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
