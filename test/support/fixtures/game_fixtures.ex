defmodule Teiserver.GameFixtures do
  @moduledoc false
  alias Teiserver.Game
  alias Teiserver.Game.{Lobby, Match, MatchType, MatchMembership, MatchSettingType, MatchSetting}
  import Teiserver.AccountFixtures, only: [user_fixture: 0]
  import Teiserver.ConnectionFixtures, only: [client_fixture: 0]

  @spec lobby_fixture() :: Lobby.t()
  @spec lobby_fixture(map) :: Lobby.t()
  def lobby_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    %Lobby{
      id: data["id"] || r,
      match_id: data["match_id"] || unstarted_match_fixture().id,
      match_ongoing?: data["match_ongoing?"] || false,
      host_id: data["host_id"] || user_fixture().id,
      host_data: data["host_data"] || %{},
      name: data["name"] || "lobby_#{r}",
      tags: data["tags"] || ["tag1", "tag2"],
      password: data["password"] || nil,
      locked?: data["locked?"] || false,
      public?: data["public?"] || true,
      match_type: data["match_type"] || match_type_fixture().id,
      rated?: data["rated"] || true,
      queue_id: data["queue_id"] || nil,
      game_name: data["game_name"] || "game_name_#{r}",
      game_version: data["game_version"] || "game_version_#{r}",

      # Game stuff
      game_settings: data["game_settings"] || %{},
      players: data["players"] || [],
      spectators: data["spectators"] || [],
      members: data["members"] || (data["players"] || []) ++ (data["spectators"] || [])
    }
  end

  @doc """
  Creates a host user and connection, then creates a lobby process using this

  Note: You will need to ensure `:async` is set to false as
  """
  @spec lobby_fixture_with_process() :: {pid, Teiserver.Account.User, Lobby.id()}
  def lobby_fixture_with_process() do
    {host_conn, host_user} = client_fixture()
    {:ok, lobby_id} = Game.open_lobby(host_user.id, "LobbyFixture_#{host_user.id}")
    {host_conn, host_user, lobby_id}
  end

  @spec match_type_fixture() :: MatchType.t()
  @spec match_type_fixture(map) :: MatchType.t()
  def match_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    MatchType.changeset(
      %MatchType{},
      %{
        name: data["name"] || "match_setting_type_#{r}"
      }
    )
    |> Teiserver.Repo.insert!()
  end

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
        lobby_opened_at: data["lobby_opened_at"] || Timex.now() |> Timex.shift(minutes: -5)
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

        # Outcome
        team_count: data["team_count"] || 2,
        team_size: data["team_size"] || 2,
        processed?: false,
        game_type: data["game_type"] || "match_game_type_#{r}",
        lobby_opened_at: data["lobby_opened_at"] || Timex.now() |> Timex.shift(minutes: -5),
        match_started_at: data["match_started_at"] || Timex.now() |> Timex.shift(minutes: -3),
        host_id: data["host_id"] || user_fixture().id,
        type_id: data["type_id"] || match_type_fixture().id
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec completed_match_fixture() :: Match.t()
  @spec completed_match_fixture(map) :: Match.t()
  def completed_match_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    match_started_at = data["match_started_at"] || Timex.now() |> Timex.shift(minutes: -3)
    match_ended_at = data["match_started_at"] || Timex.now() |> Timex.shift(minutes: -3)

    Match.changeset(
      %Match{},
      %{
        name: data["name"] || "match_name_#{r}",
        tags: data["tags"] || ["tag1_#{r}", "tag2_#{r}"],
        public?: data["public?"] || true,
        rated?: data["rated?"] || true,
        game_name: data["game_name"] || "match_game_name_#{r}",
        game_version: data["game_version"] || "123.456.789",
        winning_team: data["winning_team"] || 1,
        team_count: data["team_count"] || 2,
        team_size: data["team_size"] || 2,
        processed?: data["processed?"] || false,
        game_type: data["game_type"] || "match_game_type_#{r}",
        lobby_opened_at: data["lobby_opened_at"] || Timex.now() |> Timex.shift(minutes: -5),
        match_started_at: match_started_at,
        match_ended_at: match_ended_at,
        match_duration_seconds: Timex.diff(match_ended_at, match_started_at, :second),
        host_id: data["host_id"] || user_fixture().id,
        type_id: data["type_id"] || match_type_fixture().id
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

  @spec match_setting_type_fixture() :: Match.t()
  @spec match_setting_type_fixture(map) :: Match.t()
  def match_setting_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    MatchSettingType.changeset(
      %MatchSettingType{},
      %{
        name: data["name"] || "match_setting_type_#{r}"
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec match_setting_fixture() :: Match.t()
  @spec match_setting_fixture(map) :: Match.t()
  def match_setting_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    MatchSetting.changeset(
      %MatchSetting{},
      %{
        type_id: data["type_id"] || match_setting_type_fixture().id,
        match_id: data["match_id"] || completed_match_fixture().id,
        value: data["value"] || "value_#{r}"
      }
    )
    |> Teiserver.Repo.insert!()
  end
end
