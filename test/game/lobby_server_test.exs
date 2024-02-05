defmodule Teiserver.Game.LobbyServerTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Game
  alias Teiserver.{AccountFixtures, ConnectionFixtures}

  describe "Lobby server" do
    test "server lifecycle" do
      r = :rand.uniform(999_999_999)
      {conn, user} = ConnectionFixtures.client_fixture()

      # Now we host a game with this user
      {:ok, lobby_id} = Game.start_lobby_server(user.id, "Lobby #{r}}")

      lobby = Game.get_lobby(lobby_id)
      assert lobby.host_id == user.id
      assert lobby.name == "Lobby #{r}}"

      # User disconnects
      TestConn.stop(conn)

      flunk "In what way do we update the lobby to show the host is disconnected?"
    end
  end
end
