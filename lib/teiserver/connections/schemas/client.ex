defmodule Teiserver.Connections.Client do
  @moduledoc """
  # Client
  A client represents the logged in instance of a user. Clients are not persisted in the database, instead they are present only in the `Teiserver.Connections.ClientServer` processes.

  ### Attributes

  * `:id` - The user_id of the User being represented
  * `:connected?` - When true, at least one connection for the client is still live, when false no connections for the client are live
  * `:lobby_id` - nil or the id of the lobby current occupied by this client
  * `:in_game?` - True when the client is in-game
  * `:afk?` - True when the client has not sent an activity message for a while
  * `:ready?` - A flag set by the client to show it is ready to proceed in the current lobby
  * `:player?` - When in a lobby or match, set to true if the client is playing and false if not (e.g. spectator)
  * `:player_number` - The numerical ID of the player within a lobby or match
  * `:team_number` - The numerical ID of the team the player is present on within a lobby or match
  * `:team_colour` - The colour used to represent this client, it is a freeform string so you are able to extend and overload this as you see fit
  * `:sync` - A map used for storing keys of items the client needs to sync and the values representing their state of syncing
  * `:lobby_host?` - Set to true if the client is the host of the lobby in question
  * `:party_id` - The ID of the party the client is part of or nil if not in a party
  """

  @type t :: %__MODULE__{
          id: Teiserver.user_id(),
          connected?: boolean,

          # Lobby status stuff
          lobby_id: Teiserver.lobby_id() | nil,
          in_game?: boolean,
          afk?: boolean,
          ready?: boolean,
          player?: boolean,
          player_number: non_neg_integer() | nil,
          team_number: non_neg_integer() | nil,
          team_colour: String.t() | nil,
          sync: map | nil,
          lobby_host?: boolean,
          party_id: Teiserver.party_id() | nil
        }

  defstruct ~w(id connected? lobby_id in_game? afk? ready? player? player_number team_number team_colour sync lobby_host? party_id)a

  @spec new(Teiserver.user_id()) :: __MODULE__.t()
  def new(user_id) do
    %__MODULE__{
      id: user_id,
      connected?: false,

      # Lobby status stuff
      lobby_id: nil,
      in_game?: false,
      afk?: false,
      ready?: false,
      player?: false,
      player_number: nil,
      team_number: nil,
      team_colour: nil,
      sync: nil,
      lobby_host?: false,
      party_id: nil
    }
  end
end
