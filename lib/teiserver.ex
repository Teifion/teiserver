defmodule Teiserver do
  use Supervisor

  alias Teiserver.{Config, Registry}

  @moduledoc """
  Documentation for `Teiserver`.

  Copied from Oban and tweaked.

  ## Main guides:
  - [Installation](guides/installation.md)
  - [Hello world](guides/hello_world.md)

  ## Contexts
  These are the main modules you will be interacting with in Teiserver. They typically delegate all their functions to something more specific but the context module will be the preferred point of contact with the Teiserver library.
  """
  @type name :: term()

  @type user_id :: non_neg_integer()
  @type lobby_id :: non_neg_integer()
  @type party_id :: non_neg_integer()

  @type option ::
          {:log, false | Logger.level()}
          | {:name, name()}
          | {:node, String.t()}
          | {:prefix, false | String.t()}
          | {:repo, module()}

  @doc """
  Starts an `Teiserver` supervision tree linked to the current process.

  ## Options

  These options are required; without them the supervisor won't start:

  * `:repo` — specifies the Ecto repo used to persist data

  ### Primary Options

  These options determine what the system does at a high level, i.e. which queues to run:

  * `:log` — either `false` to disable logging or a standard log level (`:error`, `:warning`,
    `:info`, `:debug`, etc.). This determines whether queries are logged or not; overriding the
    repo's configured log level. Defaults to `false`, where no queries are logged.

  * `:name` — used for supervisor registration, it must be unique across an entire VM instance.
    Defaults to `Teiserver` when no name is provided.

  * `:node` — used to identify the node that the supervision tree is running in. If no value is
    provided it will use the `node` name in a distributed system, or the `hostname` in an isolated
    node. See "Node Name" below.

  * `:prefix` — the query prefix, or schema, to use for inserting and executing jobs. A
    `settings_site` table must exist within the prefix.

  ## Example

  Start a stand-alone `Teiserver` instance:

      {:ok, pid} = Teiserver.start_link(repo: MyApp.Repo)

  To start an `Teiserver` instance within an application's supervision tree:

      def start(_type, _args) do
        children = [MyApp.Repo, {Teiserver, repo: MyApp.Repo}]

        Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
      end

  ## Node Name

  When the `node` value hasn't been configured it is generated based on the environment:

  * In a distributed system the node name is used
  * In a Heroku environment the system environment's `DYNO` value is used
  * Otherwise, the system hostname is used
  """
  @spec start_link([option()]) :: Supervisor.on_start()
  def start_link(opts) when is_list(opts) do
    conf = Config.new(opts)

    Supervisor.start_link(__MODULE__, conf, name: Registry.via(conf.name, nil, conf))
  end

  @doc false
  @spec child_spec([option]) :: Supervisor.child_spec()
  def child_spec(opts) do
    opts
    |> super()
    |> Supervisor.child_spec(id: Keyword.get(opts, :name, __MODULE__))
  end

  @impl Supervisor
  def init(%Config{} = _conf) do
    children = []
    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Retrieve the `Teiserver.Config` struct for a named Teiserver supervision tree.

  ## Example

  Retrieve the default `Teiserver` instance config:

      %Teiserver.Config{} = Teiserver.config()

  Retrieve the config for an instance started with a custom name:

      %Teiserver.Config{} = Teiserver.config(MyCustomTeiserver)
  """
  @doc since: "0.2.0"
  @spec config(name()) :: Config.t()
  def config(name \\ __MODULE__), do: Registry.config(name)
end
