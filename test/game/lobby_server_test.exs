defmodule Teiserver.Game.LobbyServerTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.{Game, Connections}
  alias Teiserver.ConnectionFixtures

  describe "Lobby server" do
    test "server lifecycle" do
      r = :rand.uniform(999_999_999)
      {conn, user} = ConnectionFixtures.client_fixture()

      # Now we host a game with this user
      {:ok, lobby_id} = Game.start_lobby_server(user.id, "Lobby #{r}}")

      lobby = Game.get_lobby(lobby_id)
      assert lobby.host_id == user.id
      assert lobby.name == "Lobby #{r}}"

      topic = Game.lobby_topic(lobby.id)
      listener = TestConn.new(topic)

      # User disconnects
      TestConn.stop(conn)

      [m] = TestConn.get(listener)

      assert match?(
               %{
                 topic: ^topic,
                 update_id: 1,
                 event: :lobby_updated,
                 lobby: %{
                   host_data: nil
                 }
               },
               m
             )

      # Now destroy the client process
      Connections.stop_client_server(user.id)
      # Sleep to let the process die
      :timer.sleep(100)

      [m] = TestConn.get(listener)

      assert m == %{
               event: :lobby_closed,
               lobby_id: lobby_id,
               topic: topic
             }
    end
  end
end
