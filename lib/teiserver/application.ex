defmodule Teiserver.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # children = [
    #   {Registry, [keys: :unique, members: :auto, name: Teiserver.Registry]},
    #   {Registry, [keys: :unique, members: :auto, name: Teiserver.ClientRegistry]},
    # ]

    # # See https://hexdocs.pm/elixir/Supervisor.html
    # # for other strategies and supported options
    # opts = [strategy: :one_for_one, name: Teiserver.Supervisor]
    # Supervisor.start_link(children, opts)

    Supervisor.start_link(
      [Teiserver.Registry],
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
