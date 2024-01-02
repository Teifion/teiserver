defmodule Teiserver.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Teiserver.Registry,
      {Phoenix.PubSub, name: Teiserver.PubSub},


      # Clients and connections
      {Registry, [keys: :duplicate, members: :auto, name: Teiserver.ConnectionRegistry]},
      {Registry, [keys: :unique, members: :auto, name: Teiserver.ClientRegistry]},
      {DynamicSupervisor, strategy: :one_for_one, name: Teiserver.ClientSupervisor}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
