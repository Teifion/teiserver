defmodule Teiserver.Game.LobbyLibSyncTest do
  @moduledoc false
  use Teiserver.Case, async: false

  alias Teiserver.Game
  alias Teiserver.Game.LobbyLib
  alias Teiserver.Fixtures.{ConnectionFixtures, GameFixtures}

  describe "LobbyLib" do
    test "Creating and stopping server" do
      assert_raise FunctionClauseError, fn -> Game.start_lobby_server(nil, "Lobby name") end

      # The fact it's not got a working userid isn't important, we don't check the DB
      # it just needs to not be nil
      {:ok, %{id: lobby_id1}} = Game.start_lobby_server(Teiserver.uuid(), "lobby1_name")
      assert is_binary(lobby_id1)
      assert lobby_id1 > 0
      assert Game.get_lobby(lobby_id1).name == "lobby1_name"

      {_conn, user} = ConnectionFixtures.client_fixture()

      {:ok, %{id: lobby_id2}} = Game.start_lobby_server(user.id, "Lobby name")
      assert is_binary(lobby_id2)
      assert lobby_id2 > 0
      assert Game.get_lobby(lobby_id2).name == "Lobby name"

      assert Game.lobby_exists?(lobby_id1)
      assert Game.lobby_exists?(lobby_id2)

      Game.stop_lobby_server(lobby_id1)
      :timer.sleep(50)

      refute Game.lobby_exists?(lobby_id1)
      assert Game.lobby_exists?(lobby_id2)

      Game.stop_lobby_server(lobby_id2)
      :timer.sleep(50)

      refute Game.lobby_exists?(lobby_id1)
      refute Game.lobby_exists?(lobby_id2)
    end

    test "list_lobby_summaries" do
      {_host_conn, _host_user, lobby1_id} = GameFixtures.lobby_fixture_with_process()
      {_host_conn, _host_user, lobby2_id} = GameFixtures.lobby_fixture_with_process()
      {_host_conn, _host_user, lobby3_id} = GameFixtures.lobby_fixture_with_process()

      # The test is async so it's possible other lobbies are being created while this runs
      lobby_list = Game.stream_lobby_summaries() |> Enum.to_list()
      lobby_list_ids = Enum.map(lobby_list, fn l -> l.id end)

      assert Enum.member?(lobby_list_ids, lobby1_id)
      assert Enum.member?(lobby_list_ids, lobby2_id)
      assert Enum.member?(lobby_list_ids, lobby3_id)

      # Now just two of them
      lobby_list =
        Game.stream_lobby_summaries(%{"ids" => [lobby1_id, lobby2_id]}) |> Enum.to_list()

      assert Enum.count(lobby_list) == 2
      lobby_list_ids = Enum.map(lobby_list, fn l -> l.id end)

      assert Enum.member?(lobby_list_ids, lobby1_id)
      assert Enum.member?(lobby_list_ids, lobby2_id)
      refute Enum.member?(lobby_list_ids, lobby3_id)

      # Now with a dud filter
      lobby_list =
        Game.stream_lobby_summaries(%{"dud-filter" => [lobby1_id, lobby2_id]}) |> Enum.to_list()

      lobby_list_ids = Enum.map(lobby_list, fn l -> l.id end)

      assert Enum.member?(lobby_list_ids, lobby1_id)
      assert Enum.member?(lobby_list_ids, lobby2_id)
      assert Enum.member?(lobby_list_ids, lobby3_id)

      # Cleanup
      Game.stop_lobby_server(lobby1_id)
      Game.stop_lobby_server(lobby2_id)
      Game.stop_lobby_server(lobby3_id)
    end

    test "list_lobby_ids" do
      {_host_conn, _host_user, lobby1_id} = GameFixtures.lobby_fixture_with_process()
      {_host_conn, _host_user, lobby2_id} = GameFixtures.lobby_fixture_with_process()
      {_host_conn, _host_user, lobby3_id} = GameFixtures.lobby_fixture_with_process()

      # The test is async so it's possible other lobbies are being created while this runs
      lobby_ids = Game.list_lobby_ids()
      local_lobby_ids = Game.list_local_lobby_ids()

      # In theory we're not on a cluster so these _should_ be the same
      # it is possible multiple tests running at once could create a lobby in between these
      # two, if that starts happening we probably just want to retry it a few times
      # Notably there is no promise they are in the same order so we sort them
      assert Enum.sort(lobby_ids) == Enum.sort(local_lobby_ids)

      assert Enum.member?(lobby_ids, lobby1_id)
      assert Enum.member?(lobby_ids, lobby2_id)
      assert Enum.member?(lobby_ids, lobby3_id)

      # Cleanup
      Game.stop_lobby_server(lobby1_id)
      Game.stop_lobby_server(lobby2_id)
      Game.stop_lobby_server(lobby3_id)
    end

    test "get_lobby_attribute/2" do
      {_host_conn, host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()

      assert Game.get_lobby_attribute(lobby_id, :host_id) == host_user.id

      # Cleanup
      Game.stop_lobby_server(lobby_id)
    end

    test "get_lobby/1" do
      {_host_conn, host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()

      assert Game.get_lobby(lobby_id).host_id == host_user.id

      # Cleanup
      Game.stop_lobby_server(lobby_id)
    end

    test "get_lobby_summary/1" do
      {_host_conn, host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()

      assert Game.get_lobby_summary(lobby_id).host_id == host_user.id

      # Cleanup
      Game.stop_lobby_server(lobby_id)
    end

    test "cast_lobby/2" do
      {_host_conn, _host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()

      assert LobbyLib.cast_lobby(Teiserver.uuid(), :cycle_lobby) == nil
      assert LobbyLib.cast_lobby(lobby_id, :cycle_lobby) == :ok
      Game.stop_lobby_server(lobby_id)
    end

    test "stop_lobby_server/2" do
      {_host_conn, _host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()
      assert Game.lobby_exists?(lobby_id)

      assert Game.stop_lobby_server(Teiserver.uuid()) == nil
      assert Game.lobby_exists?(lobby_id)

      assert Game.stop_lobby_server(lobby_id) == :ok
      refute Game.lobby_exists?(lobby_id)
    end

    test "lobby_end_match/1" do
      {_host_conn, _host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()
      # Start the match so we can end it
      LobbyLib.lobby_start_match(lobby_id)
      :timer.sleep(1000)
      started_state = Game.get_lobby(lobby_id)
      assert started_state.match_ongoing?

      LobbyLib.lobby_end_match(lobby_id)
      :timer.sleep(500)
      ended_state = Game.get_lobby(lobby_id)
      refute ended_state.match_ongoing?

      assert started_state.match_id != ended_state.match_id
    end

    test "subscriptions" do
      {_host_conn, _host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()
      lobby = Game.get_lobby(lobby_id)

      {conn1, _user1} = ConnectionFixtures.client_fixture()
      {conn2, _user2} = ConnectionFixtures.client_fixture()

      TestConn.run(conn1, fn -> Game.subscribe_to_lobby(lobby.id) end)

      assert TestConn.get(conn1) == []
      assert TestConn.get(conn2) == []

      topic = Game.lobby_topic(lobby.id)
      Teiserver.broadcast(topic, %{event: :test_message, msg: "test"})

      assert TestConn.get(conn1) == [%{msg: "test", event: :test_message, topic: topic}]
      assert TestConn.get(conn2) == []

      TestConn.run(conn1, fn -> Game.unsubscribe_from_lobby(lobby.id) end)

      Teiserver.broadcast(topic, %{event: :test_message, msg: "test2"})
      assert TestConn.get(conn1) == []
      assert TestConn.get(conn2) == []

      Game.stop_lobby_server(lobby_id)
    end
  end
end
