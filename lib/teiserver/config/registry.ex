defmodule Teiserver.Registry do
  @moduledoc """
  Local process storage for Teiserver instances.
  Heavily copied from Oban
  """

  @type role :: term()
  @type key :: Teiserver.name() | {Teiserver.name(), role()}
  @type value :: term()

  @doc false
  def child_spec(_arg) do
    [keys: :unique, name: __MODULE__]
    |> Registry.child_spec()
    |> Supervisor.child_spec(id: __MODULE__)
  end

  @doc """
  Fetch the config for an Teiserver supervisor instance.

  ## Example

  Get the default instance config:

      Teiserver.Registry.config(Teiserver)

  Get config for a custom named instance:

      Teiserver.Registry.config(MyApp.Teiserver)
  """
  @spec config(Teiserver.name()) :: Teiserver.Config.t()
  def config(teiserver_name) do
    case lookup(teiserver_name) do
      {_pid, config} ->
        config

      _ ->
        raise RuntimeError, """
        No Teiserver instance named `#{inspect(teiserver_name)}` is running and config isn't available.
        """
    end
  end

  @doc """
  Find the `{pid, value}` pair for a registered Teiserver process.

  ## Example

  Get the default instance config:

      Teiserver.Registry.lookup(Teiserver)

  Get a supervised module's pid:

      Teiserver.Registry.lookup(Teiserver, Teiserver.Notifier)
  """
  @spec lookup(Teiserver.name(), role()) :: nil | {pid(), value()}
  def lookup(teiserver_name, role \\ nil) do
    __MODULE__
    |> Registry.lookup(key(teiserver_name, role))
    |> List.first()
  end

  @doc """
  Returns the pid of a supervised Teiserver process, or `nil` if the process can't be found.

  ## Example

  Get the Teiserver supervisor's pid:

      Teiserver.Registry.whereis(Teiserver)

  Get a supervised module's pid:

      Teiserver.Registry.whereis(Teiserver, Teiserver.Notifier)

  Get the pid for a plugin:

      Teiserver.Registry.whereis(Teiserver, {:plugin, MyApp.Teiserver.Plugin})

  Get the pid for a queue's producer:

      Teiserver.Registry.whereis(Teiserver, {:producer, "default"})
  """
  @spec whereis(Teiserver.name(), role()) :: pid() | {atom(), node()} | nil
  def whereis(teiserver_name, role \\ nil) do
    teiserver_name
    |> via(role)
    |> GenServer.whereis()
  end

  @doc """
  Build a via tuple suitable for calls to a supervised Teiserver process.

  ## Example

  For an Teiserver supervisor:

      Teiserver.Registry.via(Teiserver)

  For a supervised module:

      Teiserver.Registry.via(Teiserver, Teiserver.Notifier)

  For a plugin:

      Teiserver.Registry.via(Teiserver, {:plugin, Teiserver.Plugins.Cron})
  """
  @spec via(Teiserver.name(), role(), value()) :: {:via, Registry, {__MODULE__, key()}}
  def via(teiserver_name, role \\ nil, value \\ nil)

  def via(teiserver_name, role, nil),
    do: {:via, Registry, {__MODULE__, key(teiserver_name, role)}}

  def via(teiserver_name, role, value),
    do: {:via, Registry, {__MODULE__, key(teiserver_name, role), value}}

  defp key(teiserver_name, nil), do: teiserver_name
  defp key(teiserver_name, role), do: {teiserver_name, role}
end
