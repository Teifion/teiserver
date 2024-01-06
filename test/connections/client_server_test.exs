defmodule Connections.ClientServerTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Connections
  alias Teiserver.AccountFixtures

  describe "Clint server" do
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

      server_state = :sys.get_state(Connections.get_client_pid(user.id))
      assert server_state.client == client
      assert server_state.connections == []
    end
  end
end
