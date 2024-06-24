defmodule Connections.ClientInLobbyLibTest do
  @moduledoc false
  use Teiserver.Case, async: false

  alias Teiserver.{Connections, Game}
  alias Teiserver.Fixtures.{ConnectionFixtures, GameFixtures}

  describe "ClientLib" do
    test "update_client_in_lobby" do
      {_host_conn, _host_user, lobby_id} = GameFixtures.lobby_fixture_with_process()
      {_conn, user} = ConnectionFixtures.client_fixture()

      Game.add_client_to_lobby(user.id, lobby_id)

      client = Connections.get_client(user.id)
      assert client.lobby_id == lobby_id
      assert client.player? == false

      Connections.update_client_in_lobby(user.id, %{player?: true}, "reason here")

      # Need to give the LobbyServer time to update us
      :timer.sleep(50)

      client = Connections.get_client(user.id)
      assert client.player? == true
    end
  end
end
