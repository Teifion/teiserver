defmodule Teiserver.Connections.Client do
  @moduledoc """
  A client represents the logged in instance of a user. Clients are not persisted in the database
  """

  @type t :: %__MODULE__{
          id: Teiserver.user_id(),
          connections: list,

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

  defstruct ~w(id connections lobby_id in_game? afk? ready? player? player_number team_number team_colour sync lobby_host? party_id)a

  @spec new(Teiserver.user_id()) :: __MODULE__.t()
  def new(user_id) do
    %__MODULE__{
      id: user_id,
      connections: [],

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
