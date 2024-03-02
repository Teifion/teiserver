defmodule Teiserver.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Teiserver.PubSub},
      Teiserver.System.ClusterManagerSupervisor,

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
      {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalLobbyRegistry]}

      # Matchmaking
      # {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.MMSupervisor},
      # {Horde.Registry, [keys: :unique, members: :auto, name: Teiserver.MMQueueRegistry]},
      # {Horde.Registry, [keys: :unique, members: :auto, name: Teiserver.MMMatchRegistry]},
      # {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalMMQueueRegistry]},
      # {Registry, [keys: :unique, members: :auto, name: Teiserver.LocalMMMatchRegistry]}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    start_result = Supervisor.start_link(children, opts)

    if Application.get_env(:teiserver, :teiserver_clustering, true) do
      Teiserver.System.ClusterManagerSupervisor.start_cluster_manager_supervisor_children()
    end

    start_result
  end
end
