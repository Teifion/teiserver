defmodule Connections.ClientLibTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Connections
  alias Teiserver.{ConnectionFixtures}

  describe "ClientLib" do
    test "server lifecycle" do
      {_conn, user} = ConnectionFixtures.client_fixture()

      Connections.get_client_pid(user.id)

      # These are used elsewhere in general but we want to ensure they are delegated
      Connections.cast_client(user.id, {:update_client, %{}})
      Connections.call_client(user.id, :get_client_state)
      Connections.stop_client_server(user.id)
    end

    test "update client" do
      {conn, user} = ConnectionFixtures.client_fixture()
      TestConn.subscribe(conn, Connections.client_topic(user.id))

      msgs = TestConn.get(conn)
      assert msgs == []

      # Check the client is as we expect
      client = Connections.get_client(user.id)
      assert client.player_number == nil

      # Now update it
      Connections.update_client(user.id, %{player_number: 123})

      # Check the client has updated
      client = Connections.get_client(user.id)
      assert client.player_number == 123

      # Should have gotten a new message too
      msgs = TestConn.get(conn)

      assert msgs == [
               %{
                 topic: Connections.client_topic(user.id),
                 event: :client_updated,
                 client: %Teiserver.Connections.Client{
                   id: user.id,
                   last_disconnected: nil,
                   connected?: true,
                   lobby_id: nil,
                   in_game?: false,
                   afk?: false,
                   ready?: false,
                   player?: false,
                   player_number: 123,
                   team_number: nil,
                   team_colour: nil,
                   sync: nil,
                   lobby_host?: false,
                   party_id: nil
                 },
                 update_id: 1
               }
             ]

      # Now try to update with the same details, should result in no change
      Connections.update_client(user.id, %{player_number: 123})

      client = Connections.get_client(user.id)
      assert client.player_number == 123

      msgs = TestConn.get(conn)
      assert msgs == []

      # Update with a different player_number, ensure we increment update_id
      Connections.update_client(user.id, %{player_number: 456})

      client = Connections.get_client(user.id)
      assert client.player_number == 456

      msgs = TestConn.get(conn)
      assert Enum.count(msgs) == 1
      [update_msg] = msgs

      assert update_msg.client.player_number == 456
      assert update_msg.update_id == 2
    end

    test "updating with a bad key" do
      {conn, user} = ConnectionFixtures.client_fixture()
      TestConn.subscribe(conn, Connections.client_topic(user.id))

      msgs = TestConn.get(conn)
      assert msgs == []

      # Now update it
      Connections.update_client(user.id, %{not_a_key: "abc"})

      # Check the client has updated
      client = Connections.get_client(user.id)
      refute Map.has_key?(client, :not_a_key)

      # No messages either, client should be the same
      msgs = TestConn.get(conn)
      assert msgs == []
    end
  end
end
