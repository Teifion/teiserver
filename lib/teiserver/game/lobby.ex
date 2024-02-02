defmodule Teiserver.Game.Lobby do
  @moduledoc """
  # Lobby
  A lobby is a place for users to gather and form a game instance. Once the lobby starts it becomes a match, once the match ends the users return to the lobby.

  ### Attributes

  * `:id` - The id of the lobby in question
  * `:match_id` - The id of the match for this lobby
  * `:match_ongoing` - True if the match is currently in progress
  * `:host_data` - A map of the data relevant to the host of the game
  * `:name` - The name of the lobby as displayed in lobby lists
  * `:password` - The (plaintext) password for the lobby, nil if no password
  * `:locked` - Boolean of the room being locked to the general public at this stage
  * `:public` - Boolean of the room being public or not
  * `:queue_id` - The ID of the queue (matchmaking) this lobby belongs to
  * `:engine_name` - String of the engine name
  * `:engine_version` - String of the engine version
  * `:game_name` - String of the game name
  * `:game_version` - String of the game version
  * `:game_settings` - Map of the settings to be used in starting the game
  * `:map_name` - Name of the map selected
  * `:players` - List of user_ids as players, source of truth is still client state
  * `:spectators` - List of user_ids spectating, source of truth is still client state
  * `:members` - Total list of all user_ids who are members of the lobby

  """

  use TypedStruct

  @type id :: non_neg_integer()

  typedstruct do
    @typedoc "A lobby"

    field :id, id()
    field :match_id, non_neg_integer()
    field :match_ongoing, boolean(), default: false

    # Host stuff
    field :host_data, map(), default: %{}
      # ip: String.t()
      # port: non_neg_integer()

    # Discoverability
    field :name, String.t()
    field :password, String.t(), default: nil
    field :locked, boolean(), default: false
    # When set to false updates to this lobby won't appear in global_battle updates
    field :public, boolean(), default: true
    field :queue_id, non_neg_integer(), default: nil

    # Game version stuff
    field :engine_name, String.t()
    field :engine_version, String.t()

    field :game_name, String.t()
    field :game_version, String.t()

    # Game stuff
    field :game_settings, map(), default: %{}
    field :map_name, String.t()

    field :players, [Teiserver.user_id()], default: []
    field :spectators, [Teiserver.user_id()], default: []
    field :members, [Teiserver.user_id()], default: []
  end

  @spec new() :: __MODULE__.t()
  def new() do
    id = 123
    %__MODULE__{
      id: id,
      name: "Lobby #{id}"
    }
  end
end
