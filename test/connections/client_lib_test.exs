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
  end
end
