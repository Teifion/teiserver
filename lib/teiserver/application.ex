defmodule Teiserver.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Teiserver.Repo,
      # Teiserver.Registry,
      {Phoenix.PubSub, name: Teiserver.PubSub},

      # Servers not part of the general slew of things
      {Registry, [keys: :unique, members: :auto, name: Teiserver.ServerRegistry]},

      # Clients and connections,
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.ClientSupervisor},
      {Horde.Registry, [keys: :unique, members: :auto, name: Teiserver.HordeClientRegistry]},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.ClientRegistry]},
      # Teiserver.Connections.LoginThrottleServer,

      # Parties
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.PartySupervisor},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.PartyRegistry]},

      # Lobbies
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.LobbySupervisor},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.LobbyRegistry]},
      Teiserver.LobbyIdServer,

      # Matchmaking
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.MMSupervisor},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.MMQueueRegistry]},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.MMMatchRegistry]}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
