defmodule Teiserver do
  use Supervisor

  alias Teiserver.{Config, Registry}

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

  @moduledoc """
  Teiserver is a game middleware server library. Its role is to handle the common and game-agnostic issues while allowing you to handle the game-specific items you want included. Teiserver has generic handlers for users, lobbies, chat and more allowing for game-specific overrides.

  In a peer-to-peer setting each client will communicate to each other client as and when they need to. With a middleware server every client communicates via the middleware server and the server acts as a single source of truth.

  ```mermaid
  graph TD;
    srv{{Teiserver}};
    srv <--> User1;
    srv <--> User2;
    srv <--> User3;
    srv <--> User4;
    Host1 <--> srv;
    Host2 <--> srv;
    Bot1 <--> srv;
    Bot2 <--> srv;
  ```

  ## Main guides:
  - [Installation](guides/installation.md)
  - [Hello world](guides/hello_world.md)
  - [Program structure](guides/program_structure.md)
  - [Snippets](guides/snippets.md)

  ## Contexts
  These are the main modules you will be interacting with in Teiserver. They typically delegate all their functions to something more specific but the context module will be the preferred point of contact with the Teiserver library.

  Teiserver has some other publicly accessible functions for those who want to write more advanced or complex functionality but in theory everything you need should be accessible from the relevant context.

  ### Context overview
  - **Accounts**: Users
  - **Communication**: Chat
  - **Connections**: User activity
  - **Game**: Game functionality (e.g. matchmaking)
  - **Lobby**: Game lobbies
  - **Logging**: Logging of events and numbers
  - **Moderation**: Handling disruptive users
  - **Settings**: Key-Value pairs for users and the system
  - **Telemetry**: Moment to moment events

  # Teiserver module
  Starts a `Teiserver` supervision tree linked to the current process.

  ## Required config

  This option is required; without them the server supervisor won't start:

  * `:repo` — specifies the Ecto repo used to persist data

  ### Optional config

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
