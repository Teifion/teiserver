defmodule Teiserver.ConnectionFixtures do
  @moduledoc false

  alias Teiserver.Connections
  alias Teiserver.TestSupport.TestConn

  @spec client_fixture(Teiserver.Account.User) :: {pid, Teiserver.Account.User}
  def client_fixture(user \\ nil) do
    user = user || Teiserver.AccountFixtures.user_fixture()
    conn = TestConn.new()

    TestConn.run(conn, fn ->
      Connections.connect_user(user.id)
    end)

    :timer.sleep(100)

    {conn, user}
  end
end
