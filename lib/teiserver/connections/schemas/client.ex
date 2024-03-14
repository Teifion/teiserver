defmodule Teiserver.Connections.Client do
  @moduledoc """
  # Client
  A client represents the logged in instance of a user. Clients are not persisted in the database, instead they are present only in the `Teiserver.Connections.ClientServer` processes.

  ### Attributes

  * `:id` - The user_id of the User being represented
  * `:connected?` - When true, at least one connection for the client is still live, when false no connections for the client are live
  * `:last_disconnected` - When disconnected, stores a DateTime of when the client was last connected
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

  * `:update_id` - The version ID of the update to ensure updates can be discarded if out of date or duplicates
  """

  use TypedStruct

  @derive {Jason.Encoder,
           only:
             ~w(id connected? last_disconnected afk? party_id in_game? lobby_id ready? player? player_number team_number team_colour sync lobby_host? update_id)a}
  typedstruct do
    field(:id, Teiserver.user_id())
    field(:connected?, boolean, default: false)
    field(:last_disconnected, DateTime.t())

    field(:afk?, boolean, default: false)
    field(:party_id, Teiserver.party_id())
    field(:in_game?, boolean, default: false)

    # Lobby status stuff
    field(:lobby_id, Teiserver.lobby_id())
    field(:ready?, boolean, default: false)
    field(:player?, boolean, default: false)
    field(:player_number, non_neg_integer())
    field(:team_number, non_neg_integer())
    field(:team_colour, String.t())
    field(:sync, map | nil)
    field(:lobby_host?, boolean, default: false)

    # Meta
    field(:update_id, non_neg_integer())
  end

  @spec new(Teiserver.user_id()) :: __MODULE__.t()
  def new(user_id) do
    %__MODULE__{
      id: user_id,
      update_id: 0
    }
  end
end
