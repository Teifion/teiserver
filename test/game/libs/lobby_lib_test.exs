defmodule Teiserver.Game.LobbyLibTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Game
  alias Teiserver.{ConnectionFixtures, GameFixtures}

  describe "LobbyLib" do
    test "Creating and stopping server" do
      assert_raise FunctionClauseError, fn -> Game.start_lobby_server(nil, "Lobby name") end

      # The fact it's not got a working userid isn't important, we don't check the DB
      # it just needs to not be nil
      {:ok, lobby_id1} = Game.start_lobby_server(Ecto.UUID.generate(), nil)
      assert is_binary(lobby_id1)
      assert lobby_id1 > 0
      assert Game.get_lobby(lobby_id1).name == "Lobby ##{lobby_id1}"

      {_conn, user} = ConnectionFixtures.client_fixture()

      {:ok, lobby_id2} = Game.start_lobby_server(user.id, "Lobby name")
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

    test "open_lobby" do
    end

    test "list_lobby_summaries" do
      {_host_conn, _host_user, lobby1_id} = GameFixtures.lobby_fixture_with_process()
      {_host_conn, _host_user, lobby2_id} = GameFixtures.lobby_fixture_with_process()
      {_host_conn, _host_user, lobby3_id} = GameFixtures.lobby_fixture_with_process()

      # The test is async so it's possible other lobbies are being created while this runs
      lobby_list = Game.list_lobby_summaries()
      lobby_list_ids = Enum.map(lobby_list, fn l -> l.id end)

      assert Enum.member?(lobby_list_ids, lobby1_id)
      assert Enum.member?(lobby_list_ids, lobby2_id)
      assert Enum.member?(lobby_list_ids, lobby3_id)

      # Now just two of them
      lobby_list = Game.list_lobby_summaries([lobby1_id, lobby2_id])
      assert Enum.count(lobby_list) == 2
      lobby_list_ids = Enum.map(lobby_list, fn l -> l.id end)

      assert Enum.member?(lobby_list_ids, lobby1_id)
      assert Enum.member?(lobby_list_ids, lobby2_id)
      refute Enum.member?(lobby_list_ids, lobby3_id)
    end

    test "list_lobby_ids" do
      {_host_conn, _host_user, lobby1_id} = GameFixtures.lobby_fixture_with_process()
      {_host_conn, _host_user, lobby2_id} = GameFixtures.lobby_fixture_with_process()
      {_host_conn, _host_user, lobby3_id} = GameFixtures.lobby_fixture_with_process()

      # The test is async so it's possible other lobbies are being created while this runs
      lobby_ids = Game.list_lobby_ids()

      assert Enum.member?(lobby_ids, lobby1_id)
      assert Enum.member?(lobby_ids, lobby2_id)
      assert Enum.member?(lobby_ids, lobby3_id)
    end

    test "get_lobby_attribute/2" do
      {_host_conn, host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()

      assert Game.get_lobby_attribute(lobby_id, :host_id) == host_user.id
    end

    test "get_lobby/1" do
      {_host_conn, host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()

      assert Game.get_lobby(lobby_id).host_id == host_user.id
    end

    test "get_lobby_summary/1" do
      {_host_conn, host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()

      assert Game.get_lobby_summary(lobby_id).host_id == host_user.id
    end
  end
end
