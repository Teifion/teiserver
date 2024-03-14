defmodule Teiserver.Game.Lobby do
  @moduledoc """
  # Lobby
  A lobby is a place for users to gather and form a game instance. Once the lobby starts it becomes a match, once the match ends the users return to the lobby.

  For a guide on the lifecycle of lobbies and matches please see the [`Match lifecycle guide`](match_lifecycle.html).

  ### Attributes

  * `:id` - The id of the lobby in question
  * `:match_id` - The id of the match for this lobby
  * `:host_id` - The user_id of the creator of the lobby
  * `:match_ongoing?` - True if the match is currently in progress
  * `:host_data` - A map of the data relevant to the host of the game, if the data is set to nil it means the host is currently disconnected but the ClientServer process has yet to time out
  * `:name` - The name of the lobby as displayed in lobby lists
  * `:tags` - A list of strings representing tagged values
  * `:password` - The (plaintext) password for the lobby, nil if no password
  * `:passworded?` - Boolean of the room having a password or not, overloads the :password property for ease of use
  * `:locked?` - Boolean of the room being locked to the general public at this stage
  * `:public?` - Boolean of the room being public or not, when set to false updates to this lobby won't appear in global_battle updates
  * `:match_type` - MatchType.id of the type of match this will be
  * `:rated?` - When set to true it means the game will be rated (assuming all other requirements are met)
  * `:queue_id` - The ID of the queue (matchmaking) this lobby belongs to
  * `:game_name` - String of the game name
  * `:game_version` - String of the game version
  * `:game_settings` - Map of the settings to be used in starting the game
  * `:players` - List of user_ids as players, source of truth is still client state
  * `:spectators` - List of user_ids spectating, source of truth is still client state
  * `:members` - Total list of all user_ids who are members of the lobby

  """

  use TypedStruct

  @type id :: Ecto.UUID.t()
  @type name :: String.t()

  @derive {Jason.Encoder,
           only:
             ~w(id match_id match_ongoing? host_id host_data name tags password passworded? locked? public? match_type rated? queue_id game_name game_version game_settings players spectators members)a}
  typedstruct do
    @typedoc "A lobby"

    field(:id, id())
    field(:match_id, Teiserver.Game.Match.id())
    field(:match_ongoing?, boolean(), default: false)

    # Host stuff, not part of the match itself
    field(:host_id, Teiserver.user_id())
    field(:host_data, map() | nil, default: %{})

    # Discoverability
    field(:name, name())
    field(:tags, [String.t()], default: [])
    field(:password, String.t(), default: nil)
    field(:passworded?, boolean(), default: false)
    field(:locked?, boolean(), default: false)
    field(:public?, boolean(), default: true)
    field(:match_type, Teiserver.Game.MatchType.id(), default: nil)

    field(:rated?, boolean(), default: true)
    field(:queue_id, Teiserver.queue_id(), default: nil)

    # Game version stuff
    field(:game_name, String.t())
    field(:game_version, String.t())

    # Game stuff
    field(:game_settings, map(), default: %{})

    field(:players, [Teiserver.user_id()], default: [])
    field(:spectators, [Teiserver.user_id()], default: [])
    field(:members, [Teiserver.user_id()], default: [])
  end

  @spec new(Teiserver.user_id(), name()) :: __MODULE__.t()
  def new(host_id, name) when is_binary(host_id) do
    %__MODULE__{
      id: Teiserver.uuid(),
      host_id: host_id,
      name: name
    }
  end
end
