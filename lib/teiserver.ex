defmodule Teiserver do
  # use Supervisor

  alias Teiserver.Helpers.PubSubHelper

  @type name :: term()

  @type user_id :: non_neg_integer()
  @type lobby_id :: non_neg_integer()
  @type party_id :: non_neg_integer()

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
  - **Community**: Social interactions between players
  - **Connections**: User activity
  - **Game**: Game functionality (e.g. matchmaking)
  - **Lobby**: Game lobbies
  - **Logging**: Logging of events and numbers
  - **Moderation**: Handling disruptive users
  - **Settings**: Key-Value pairs for users and the system
  - **Telemetry**: Moment to moment events
  """

  @doc false
  @spec repo() :: Module
  def repo() do
    Application.get_env(:teiserver, :repo)
  end

  # PubSub delegations
  @doc false
  @spec broadcast(String.t(), map()) :: :ok
  defdelegate broadcast(channel, message), to: PubSubHelper
end
