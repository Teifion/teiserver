defmodule Teiserver.Game.MatchMembership do
  @moduledoc """
  # Match
  The persisted storage of players of a match after it started.

  ### Attributes
  * `:team_number` - The team this player was a member of
  * `:win?` - If the player was on the winning team
  * `:party_id` - The ID of the party the player was a member of (if any)
  * `:left_after_seconds` - The number of seconds into the game at which the player was determined to have disconnected
  * `:user` - The user in question
  * `:match` - The match in question

  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "game_match_memberships" do
    belongs_to(:user, Teiserver.Account.User, primary_key: true)
    belongs_to(:match, Teiserver.Game.Match, primary_key: true)

    field(:team_number, :integer, default: nil)

    field(:win?, :boolean, default: nil)
    field(:party_id, :string, default: nil)
    field(:left_after_seconds, :integer, default: nil)
  end

  @type t :: %__MODULE__{
          user_id: Teiserver.user_id(),
          match_id: Teiserver.match_id(),
          team_number: Teiserver.team_number(),
          win?: boolean(),
          party_id: Teiserver.party_id(),
          left_after_seconds: Teiserver.seconds()
        }

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(match_id user_id team_number win? left_after_seconds party_id)a)
    |> validate_required(~w(match_id user_id team_number)a)
    |> unique_constraint(~w(match_id user_id)a)
  end
end
