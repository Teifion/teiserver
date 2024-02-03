defmodule Teiserver.Game.Match do
  @moduledoc """
  # Match
  The persisted storage of a game.

  ### Attributes

  * `:name` - The name of the lobby at the time the match started
  * `:tags` - The lobby tags at the time of the match starting
  * `:public?` - The public flag at time of the match starting
  * `:rated?` - The rated flag at time of the match starting, updated to false if the match is later decided to be unrated
  * `:game_name` - The game_name at time of the match starting
  * `:game_version` - The game_version at time of the match starting
  * `:map_name` - The map_name at time of the match starting
  * `:winning_team` - The ID of the winning team, set to nil in a draw
  * `:team_count` - The number of teams in the game
  * `:team_size` - The size of the largest team
  * `:processed?` - A flag showing if the match has had post-match processing
  * `:game_type` - A string indicating the type of game
  * `:lobby_opened_at` - The datetime the lobby was opened at or when the previous match completed
  * `:match_started_at` - The datetime the lobby swapped to being in progress, not the actual start time of the game itself
  * `:match_finished_at` - The datetime the match ended and the players were returned to the lobby, not the actual end time of the game itself
  * `:match_duration_seconds` - The duration of the game in seconds as indicated by the game host
  * `:host` - The user account hosting the lobby

  """
  use TeiserverMacros, :schema

  schema "game_matches" do
    field(:name, :string)
    field(:tags, {:array, :string}, default: [])
    field(:public?, :boolean, default: true)
    field(:rated?, :boolean, default: true)

    field(:game_name, :string)
    field(:game_version, :string)

    # Game stuff
    field(:map_name, :string)
    field(:game_type, :string)

    # Outcome
    field(:winning_team, :integer)
    field(:team_count, :integer)
    field(:team_size, :integer)
    field(:processed?, :boolean, default: false)

    field(:lobby_opened_at, :utc_datetime)
    field(:match_started_at, :utc_datetime)
    field(:match_finished_at, :utc_datetime)

    # This will be something queried enough it's worth storing as it's own value
    field(:match_duration_seconds, :integer)

    # Memberships
    belongs_to(:host, Teiserver.Account.User)
    has_many(:members, Teiserver.Game.MatchMembership)
    has_many(:match_settings, Teiserver.Game.MatchSetting)

    # Relationships we expect to add
    # belongs_to :founder, Teiserver.Game.MatchmakingQueue
    # belongs_to :founder, Teiserver.Game.RatingType
    # has_many :ratings, Teiserver.Game.RatingLog
    # belongs_to :founder, Teiserver.Game.LobbyPolicy

    timestamps()
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          id: id(),
          name: String.t(),
          tags: [String.t()],
          public?: boolean(),
          rated?: boolean(),
          game_name: String.t(),
          game_version: String.t(),

          # Game stuff
          map_name: String.t(),

          # Outcome
          winning_team: non_neg_integer(),
          team_count: non_neg_integer(),
          team_size: non_neg_integer(),
          processed?: boolean(),
          game_type: String.t(),
          lobby_opened_at: DateTime.t(),
          match_started_at: DateTime.t(),
          match_finished_at: DateTime.t(),

          # This will be something queried enough it's worth storing as it's own value
          match_duration_seconds: non_neg_integer(),
          host_id: Teiserver.user_id(),
          host: Teiserver.Account.User.t(),
          members: list
        }

  @doc false
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(
      attrs,
      ~w(name tags public? rated? game_name game_version map_name winning_team team_count team_size processed? game_type lobby_opened_at match_started_at match_finished_at match_duration_seconds)a
    )
    |> validate_required(~w(name game_name game_version map_name lobby_opened_at)a)
  end
end
