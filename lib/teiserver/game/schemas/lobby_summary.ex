defmodule Teiserver.Game.LobbySummary do
  @moduledoc """
  # LobbySummary
  A type used to represent only part of a lobby (e.g. for lists of lobbies)

  ### Attributes

  * `:id` - The id of the lobby in question
  * `:host_id` - The user_id of the creator of the lobby
  * `:match_ongoing?` - True if the match is currently in progress
  * `:name` - The name of the lobby as displayed in lobby lists
  * `:tags` - A list of strings representing tagged values
  * `:password` - The (plaintext) password for the lobby, nil if no password
  * `:locked?` - Boolean of the room being locked to the general public at this stage
  * `:public?` - Boolean of the room being public or not, when set to false updates to this lobby won't appear in global_battle updates
  * `:rated?` - When set to true it means the game will be rated (assuming all other requirements are met)
  * `:queue_id` - The ID of the queue (matchmaking) this lobby belongs to
  * `:game_name` - String of the game name
  * `:game_version` - String of the game version
  * `:player_count` - Count of the number of players
  * `:spectator_count` - Count of the number of spectators

  """

  use TypedStruct

  typedstruct do
    @typedoc "A lobby"

    field(:id, Teiserver.lobby_id())
    field(:host_id, Teiserver.user_id())

    field(:match_ongoing?, boolean(), default: false)

    field(:name, String.t())
    field(:tags, [String.t()], default: [])
    field(:password, String.t(), default: nil)
    field(:locked?, boolean(), default: false)
    field(:public?, boolean(), default: true)
    field(:rated?, boolean(), default: true)
    field(:queue_id, Teiserver.queue_id(), default: nil)

    # Game version stuff
    field(:game_name, String.t())
    field(:game_version, String.t())

    field(:player_count, non_neg_integer(), default: [])
    field(:spectator_count, non_neg_integer(), default: [])
  end

  @spec new(Teiserver.Game.Lobby.t()) :: __MODULE__.t()
  def new(lobby) do
    %__MODULE__{
      id: lobby.id,
      host_id: lobby.host_id,
      match_ongoing?: lobby.match_ongoing?,
      name: lobby.name,
      tags: lobby.tags,
      password: lobby.password,
      locked?: lobby.locked?,
      public?: lobby.public?,
      rated?: lobby.rated?,
      queue_id: lobby.queue_id,
      game_name: lobby.game_name,
      game_version: lobby.game_version,
      player_count: Enum.count(lobby.players),
      spectator_count: Enum.count(lobby.spectators)
    }
  end
end
