defmodule Teiserver.GameFixtures do
  @moduledoc false
  alias Teiserver.Game.{Match, MatchMembership}
  import Teiserver.AccountFixtures, only: [user_fixture: 0]

  @spec unstarted_match_fixture() :: Match.t()
  @spec unstarted_match_fixture(map) :: Match.t()
  def unstarted_match_fixture(data \\ %{}) do
    Match.changeset(
      %Match{},
      %{
        public?: data["public?"] || true,
        rated?: data["rated?"] || true,
        host_id: data["host_id"] || user_fixture().id,
        processed?: false,
        lobby_opened_at: data["lobby_opened_at"] || Timex.now |> Timex.shift(minutes: -5),
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec incomplete_match_fixture() :: Match.t()
  @spec incomplete_match_fixture(map) :: Match.t()
  def incomplete_match_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    Match.changeset(
      %Match{},
      %{
        name: data["name"] || "match_name_#{r}",
        tags: data["tags"] || ["tag1_#{r}", "tag2_#{r}"],
        public?: data["public?"] || true,
        rated?: data["rated?"] || true,
        game_name: data["game_name"] || "match_game_name_#{r}",
        game_version: data["game_version"] || "123.456.789",

        # Game stuff
        map_name: data["map_name"] || "match_map_name_#{r}",

        # Outcome
        team_count: data["team_count"] || 2,
        team_size: data["team_size"] || 2,
        processed?: false,
        game_type: data["game_type"] || "match_game_type_#{r}",
        lobby_opened_at: data["lobby_opened_at"] || Timex.now |> Timex.shift(minutes: -5),
        match_started_at: data["match_started_at"] || Timex.now |> Timex.shift(minutes: -3),
        host_id: data["host_id"] || user_fixture().id,
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec completed_match_fixture() :: Match.t()
  @spec completed_match_fixture(map) :: Match.t()
  def completed_match_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    match_started_at = (data["match_started_at"] || Timex.now |> Timex.shift(minutes: -3))
    match_finished_at = (data["match_started_at"] || Timex.now |> Timex.shift(minutes: -3))

    Match.changeset(
      %Match{},
      %{
        name: data["name"] || "match_name_#{r}",
        tags: data["tags"] || ["tag1_#{r}", "tag2_#{r}"],
        public?: data["public?"] || true,
        rated?: data["rated?"] || true,
        game_name: data["game_name"] || "match_game_name_#{r}",
        game_version: data["game_version"] || "123.456.789",

        map_name: data["map_name"] || "match_map_name_#{r}",

        winning_team: data["winning_team"] || 1,
        team_count: data["team_count"] || 2,
        team_size: data["team_size"] || 2,
        processed?: data["processed?"] || false,
        game_type: data["game_type"] || "match_game_type_#{r}",
        lobby_opened_at: data["lobby_opened_at"] || Timex.now |> Timex.shift(minutes: -5),
        match_started_at: match_started_at,
        match_finished_at: match_finished_at,

        match_duration_seconds: Timex.diff(match_finished_at, match_started_at, :second),
        host_id: data["host_id"] || user_fixture().id,
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec match_membership_fixture() :: Match.t()
  @spec match_membership_fixture(map) :: Match.t()
  def match_membership_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    MatchMembership.changeset(
      %MatchMembership{},
      %{
        user_id: data["user_id"] || user_fixture().id,
        match_id: data["match_id"] || completed_match_fixture().id,

        team_number: data["team_number"] || 1,
        win?: data["win?"] || false,
        party_id: data["party_id"] || "party_id_#{r}",
        left_after_seconds: data[""] || 123
      }
    )
    |> Teiserver.Repo.insert!()
  end
end
