defmodule Connections.ClientServerTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Connections
  alias Teiserver.{AccountFixtures, ConnectionFixtures}

  describe "Client server" do
    test "server lifecycle" do
      user = AccountFixtures.user_fixture()
      conn = TestConn.new()

      # Connect the user
      refute Connections.client_exists?(user.id)

      # Start our client in the connected process
      TestConn.run(conn, fn ->
        Connections.connect_user(user.id)
      end)

      # Now we check to see it exists
      assert Connections.client_exists?(user.id)

      assert is_pid(Connections.get_client_pid(user.id))

      # Get the client
      client = Connections.get_client(user.id)
      assert client.__struct__ == Connections.Client
      assert client.id == user.id
      assert client.connected?
      assert client.last_disconnected == nil

      # Okay, now lets ensure the server state is as we expect
      server_state = :sys.get_state(Connections.get_client_pid(user.id))

      assert server_state.client == client
      assert server_state.user_id == user.id
      assert server_state.connections == [conn]

      # Kill the connecting process
      TestConn.stop(conn)

      # New states
      client = Connections.get_client(user.id)
      refute client.connected?
      assert client.last_disconnected != nil

      server_state = :sys.get_state(Connections.get_client_pid(user.id))
      assert server_state.client == client
      assert server_state.connections == []
    end

    test "multiple connections" do
      user = AccountFixtures.user_fixture()
      conn1 = TestConn.new()
      conn2 = TestConn.new()

      # Connect the user
      refute Connections.client_exists?(user.id)

      # Start our client in the connected process
      TestConn.run(conn1, fn ->
        Connections.connect_user(user.id)
      end)

      # Now we check to see it exists
      assert Connections.client_exists?(user.id)
      server_state = :sys.get_state(Connections.get_client_pid(user.id))
      assert server_state.client.connected?
      assert server_state.connections == [conn1]

      # Now connect a second time
      TestConn.run(conn2, fn ->
        Connections.connect_user(user.id)
      end)

      # Now we check to see it exists
      assert Connections.client_exists?(user.id)
      server_state = :sys.get_state(Connections.get_client_pid(user.id))
      assert server_state.client.connected?
      assert Enum.sort(server_state.connections) == Enum.sort([conn1, conn2])

      # Kill the first connection
      TestConn.stop(conn1)

      # Now we check to see it exists
      assert Connections.client_exists?(user.id)
      server_state = :sys.get_state(Connections.get_client_pid(user.id))
      assert server_state.client.connected?
      assert server_state.connections == [conn2]

      # And the 2nd
      TestConn.stop(conn2)

      # And now it should be disconnected
      assert Connections.client_exists?(user.id)
      server_state = :sys.get_state(Connections.get_client_pid(user.id))
      refute server_state.client.connected?
      assert server_state.connections == []
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

    test "heartbeat destroy process" do
      {conn, user} = ConnectionFixtures.client_fixture()

      # Kill the connecting process
      TestConn.stop(conn)

      # Set the last_disconnected to something okay
      disconnected_at = Timex.now() |> Timex.shift(seconds: -100)
      Connections.update_client(user.id, %{last_disconnected: disconnected_at})

      client = Connections.get_client(user.id)
      refute client.connected?
      assert client.last_disconnected == disconnected_at

      client_pid = Connections.get_client_pid(user.id)
      send(client_pid, :heartbeat)
      :timer.sleep(100)

      assert Connections.client_exists?(user.id)

      # Set the last_disconnected to something much larger, it should result in the client process being destroyed
      disconnected_at = Timex.now() |> Timex.shift(seconds: -1_000_000)
      Connections.update_client(user.id, %{last_disconnected: disconnected_at})

      client = Connections.get_client(user.id)
      refute client.connected?
      assert client.last_disconnected == disconnected_at

      client_pid = Connections.get_client_pid(user.id)
      send(client_pid, :heartbeat)
      :timer.sleep(100)

      refute Connections.client_exists?(user.id)
    end
  end
end
