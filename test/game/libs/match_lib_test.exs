defmodule Teiserver.MatchLibAsyncTest do
  @moduledoc false
  alias Teiserver.Game.Match
  use Teiserver.Case, async: true

  alias Teiserver.{Game, Connections}
  alias Teiserver.{GameFixtures, AccountFixtures, ConnectionFixtures}

  defp valid_attrs do
    %{
      name: "some name",
      public?: true,
      rated?: true,
      host_id: AccountFixtures.user_fixture().id
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      public?: false,
      rated?: false,
      host_id: AccountFixtures.user_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      public?: nil,
      rated?: nil,
      host_id: nil
    }
  end

  describe "match" do
    alias Teiserver.Game.Match

    test "match_query/0 returns a query" do
      q = Game.match_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match/0 returns match" do
      # No match yet
      assert Game.list_matches([]) == []

      # Add a match
      GameFixtures.completed_match_fixture()
      assert Game.list_matches([]) != []
    end

    test "get_match!/1 and get_match/1 returns the match with given id" do
      match = GameFixtures.completed_match_fixture()
      assert Game.get_match!(match.id) == match
      assert Game.get_match(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      assert {:ok, %Match{} = match} =
               Game.create_match(valid_attrs())

      assert match.name == "some name"
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_match(invalid_attrs())
    end

    test "update_match/2 with valid data updates the match" do
      match = GameFixtures.completed_match_fixture()

      assert {:ok, %Match{} = match} =
               Game.update_match(match, update_attrs())

      assert match.name == "some updated name"
      assert match.name == "some updated name"
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = GameFixtures.completed_match_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_match(match, invalid_attrs())

      assert match == Game.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = GameFixtures.completed_match_fixture()
      assert {:ok, %Match{}} = Game.delete_match(match)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_match!(match.id)
      end

      assert Game.get_match(match.id) == nil
    end

    test "change_match/1 returns a match changeset" do
      match = GameFixtures.completed_match_fixture()
      assert %Ecto.Changeset{} = Game.change_match(match)
    end
  end

  describe "lifecycle" do
    test "start and end match" do
      {_host_conn, _host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()

      # Update the lobby with some stuff we will want later
      Game.update_lobby(lobby_id, %{
        game_settings: %{"gs_1" => "v1", "gs_2" => "v2"}
      })

      {_, u1} = ConnectionFixtures.client_fixture()
      {_, u2} = ConnectionFixtures.client_fixture()
      {_, u3} = ConnectionFixtures.client_fixture()
      {_, u4} = ConnectionFixtures.client_fixture()
      u5 = AccountFixtures.user_fixture()

      assert Game.can_add_client_to_lobby?(u1.id, lobby_id) == {true, nil}
      assert Game.can_add_client_to_lobby?(u5.id, lobby_id) == {false, "Client is not connected"}

      Game.add_client_to_lobby(u1.id, lobby_id)
      Game.add_client_to_lobby(u2.id, lobby_id)
      Game.add_client_to_lobby(u3.id, lobby_id)
      Game.add_client_to_lobby(u4.id, lobby_id)

      assert Game.can_add_client_to_lobby?(u1.id, lobby_id) == {false, "Existing member"}

      lobby = Game.get_lobby(lobby_id)

      # Ensure the member lists is as we expect
      assert Enum.sort(lobby.members) == Enum.sort([u1.id, u2.id, u3.id, u4.id])
      assert Enum.sort(lobby.spectators) == Enum.sort([u1.id, u2.id, u3.id, u4.id])
      assert lobby.players == []

      # Update the clients by making them players and putting them on teams
      Connections.update_client_in_lobby(u1.id, %{player_number: 1, team_number: 1, player?: true}, "test")

      Connections.update_client_in_lobby(u2.id, %{player_number: 2, team_number: 1, player?: true}, "test")

      Connections.update_client_in_lobby(u3.id, %{player_number: 3, team_number: 2, player?: true}, "test")

      Connections.update_client_in_lobby(u4.id, %{player_number: 4, team_number: 2, player?: true}, "test")

      # Give the lobby time to read and update
      :timer.sleep(100)

      # Get the lobby state
      lobby = Game.get_lobby(lobby_id)

      assert Enum.sort(lobby.members) == Enum.sort([u1.id, u2.id, u3.id, u4.id])
      assert lobby.spectators == []
      assert Enum.sort(lobby.players) == Enum.sort([u1.id, u2.id, u3.id, u4.id])

      match = Game.get_match!(lobby.match_id)

      assert match.match_started_at == nil
      assert match.match_ended_at == nil

      memberships = Game.list_match_memberships(where: [match_id: match.id])
      assert memberships == []

      settings = Game.get_match_settings_map(match.id)
      assert settings == %{}

      started_match = Game.start_match(lobby.id)
      refute started_match.match_started_at == nil
      assert started_match.match_ended_at == nil

      # Now check memberships
      memberships = Game.list_match_memberships(where: [match_id: match.id])

      assert Enum.all?(memberships, fn mm -> mm.win? == nil end)
      assert Enum.all?(memberships, fn mm -> mm.left_after_seconds == nil end)

      membership_ids = memberships |> Enum.map(fn mm -> mm.user_id end)
      assert Enum.sort(membership_ids) == Enum.sort([u1.id, u2.id, u3.id, u4.id])

      # Settings
      settings = Game.get_match_settings_map(match.id)
      assert settings == %{"gs_1" => "v1", "gs_2" => "v2"}

      # Match takes place, great things happen
      :timer.sleep(100)

      outcome = %{
        winning_team: 1,
        ended_normally?: true,
        players: %{
          u1.id => %{},
          u2.id => %{},
          u3.id => %{left_after_seconds: 1},
          u4.id => %{}
        }
      }

      finished_match = Game.end_match(match.id, outcome)
      refute finished_match.match_ended_at == nil

      # Now check memberships
      memberships = Game.list_match_memberships(where: [match_id: match.id])

      assert Enum.all?(memberships, fn mm ->
               mm.win? == if mm.team_number == 1, do: true, else: false
             end)

      assert Enum.all?(memberships, fn mm ->
               mm.left_after_seconds == if mm.user_id == u3.id, do: 1, else: nil
             end)

      membership_ids = memberships |> Enum.map(fn mm -> mm.user_id end)
      assert Enum.sort(membership_ids) == Enum.sort([u1.id, u2.id, u3.id, u4.id])

      # Now remove the losers, they got upset and left!
      Game.remove_client_from_lobby(u3.id, lobby_id)
      Game.remove_client_from_lobby(u4.id, lobby_id)

      :timer.sleep(100)

      lobby = Game.get_lobby(lobby_id)

      # Ensure the member lists is as we expect
      assert Enum.sort(lobby.members) == Enum.sort([u1.id, u2.id])
      assert Enum.sort(lobby.players) == Enum.sort([u1.id, u2.id])
      assert lobby.spectators == []

      # Cycle the lobby
      Game.cycle_lobby(lobby_id)
      lobby = Game.get_lobby(lobby_id)

      assert lobby.match_id != match.id
      assert Game.get_match!(lobby.match_id)

      # Now close the lobby
      Game.close_lobby(lobby_id)
      assert Game.get_lobby(lobby_id) == nil
    end
  end
end
