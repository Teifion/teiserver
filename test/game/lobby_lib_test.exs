defmodule Teiserver.Game.LobbyLibTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Game
  alias Teiserver.{ConnectionFixtures}

  describe "LobbyLib" do
    test "Creating and stopping server" do
      assert_raise FunctionClauseError, fn -> Game.start_lobby_server(nil, "Lobby name") end

      # The fact it's not got a working userid isn't important, we don't check the DB
      # it just needs to not be nil
      {:ok, lobby_id1} = Game.start_lobby_server(-1, nil)
      assert is_integer(lobby_id1)
      assert lobby_id1 > 0
      assert Game.get_lobby(lobby_id1).name == "Lobby ##{lobby_id1}"

      {_conn, user} = ConnectionFixtures.client_fixture()

      {:ok, lobby_id2} = Game.start_lobby_server(user.id, "Lobby name")
      assert is_integer(lobby_id2)
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
  end
end
