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

    test "heartbeat destroy process" do
      {conn, user} = ConnectionFixtures.client_fixture()

      # Kill the connecting process
      TestConn.stop(conn)

      # Set the last_disconnected to something okay
      disconnected_at = Timex.now() |> Timex.shift(seconds: -100)
      Connections.update_client(user.id, %{last_disconnected: disconnected_at}, "test-heartbeat")

      client = Connections.get_client(user.id)
      refute client.connected?
      assert client.last_disconnected == disconnected_at

      client_pid = Connections.get_client_pid(user.id)
      send(client_pid, :heartbeat)
      :timer.sleep(100)

      assert Connections.client_exists?(user.id)

      # Set the last_disconnected to something much larger, it should result in the client process being destroyed
      disconnected_at = Timex.now() |> Timex.shift(seconds: -1_000_000)
      Connections.update_client(user.id, %{last_disconnected: disconnected_at}, "test-heartbeat2")

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
