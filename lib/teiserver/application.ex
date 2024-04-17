defmodule Teiserver.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Teiserver.PubSub},
      Teiserver.System.ClusterManagerSupervisor,
      Teiserver.System.CacheClusterServer,

      # Servers not part of the general slew of things
      {Registry, [keys: :unique, members: :auto, name: Teiserver.ServerRegistry]},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalServerRegistry]},

      # Connections
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.ClientSupervisor},
      {Horde.Registry, [keys: :unique, members: :auto, name: Teiserver.ClientRegistry]},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalClientRegistry]},
      # Teiserver.Connections.LoginThrottleServer,

      # Parties
      # {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.PartySupervisor},
      # {Horde.Registry, [keys: :unique, members: :auto, name: Teiserver.PartyRegistry]},
      # {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalPartyRegistry]},

      # Lobbies
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.LobbySupervisor},
      {Horde.Registry, [keys: :unique, members: :auto, name: Teiserver.LobbyRegistry]},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalLobbyRegistry]},

      # Matchmaking
      # {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.MMSupervisor},
      # {Horde.Registry, [keys: :unique, members: :auto, name: Teiserver.MMQueueRegistry]},
      # {Horde.Registry, [keys: :unique, members: :auto, name: Teiserver.MMMatchRegistry]},
      # {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalMMQueueRegistry]},
      # {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalMMMatchRegistry]}

      # DB Lookup caches
      add_cache(:ts_server_setting_type_store),
      add_cache(:ts_server_setting_cache, ttl: :timer.minutes(1)),
      add_cache(:ts_user_setting_type_store),
      add_cache(:ts_user_setting_cache, ttl: :timer.minutes(1)),
      add_cache(:ts_user_by_user_id_cache, ttl: :timer.minutes(5)),

      # Login rate limiting
      add_cache(:ts_login_count_ip, ttl: :timer.minutes(5)),
      add_cache(:ts_login_count_user, ttl: :timer.minutes(5))
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    start_result = Supervisor.start_link(children, opts)

    if Application.get_env(:teiserver, :teiserver_clustering, true) do
      Teiserver.System.ClusterManagerSupervisor.start_cluster_manager_supervisor_children()
    end

    Teiserver.System.StartupLib.perform()

    start_result
  end

  @spec add_cache(atom) :: map()
  @spec add_cache(atom, list) :: map()
  defp add_cache(name, opts \\ []) when is_atom(name) do
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
