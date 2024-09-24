defmodule Teiserver.Game.LobbyLibAsyncTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Game

  describe "LobbyLib" do
    test "lobby_name_acceptable?/1" do
      assert Game.lobby_name_acceptable?("test name")
      assert Game.lobby_name_acceptable?("a bad word here")

      acceptable_test = fn n -> not String.contains?(n, "bad word") end
      Application.put_env(:teiserver, :fn_lobby_name_acceptor, acceptable_test)

      assert Game.lobby_name_acceptable?("test name")
      refute Game.lobby_name_acceptable?("a bad word here")
    end

    test "open_lobby" do
      # This client won't exist, thus it should fail
      assert Game.open_lobby(Teiserver.uuid(), "no-host-lobby") ==
               {:error, :client_disconnected}
    end
  end
end
