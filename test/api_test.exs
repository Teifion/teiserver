defmodule ApiTest do
  @moduledoc false
  alias Teiserver.CommunicationFixtures
  use Teiserver.Case, async: true

  alias Phoenix.PubSub
  alias Teiserver.Api
  alias Teiserver.AccountFixtures
  alias Teiserver.Account.User

  describe "API functionality" do
    test "maybe_authenticate_user_by_name/2" do
      user = AccountFixtures.user_fixture()

      assert Api.maybe_authenticate_user_by_name("--- no name ---", "password") ==
               {:error, :no_user}

      assert Api.maybe_authenticate_user_by_name(user.name, "bad_password") ==
               {:error, :bad_password}

      assert Api.maybe_authenticate_user_by_name(user.name, "password") == {:ok, user}
    end

    test "maybe_authenticate_user_by_email/2" do
      user = AccountFixtures.user_fixture()

      assert Api.maybe_authenticate_user_by_email("--- no email ---", "password") ==
               {:error, :no_user}

      assert Api.maybe_authenticate_user_by_email(user.email, "bad_password") ==
               {:error, :bad_password}

      assert Api.maybe_authenticate_user_by_email(user.email, "password") == {:ok, user}
    end

    test "maybe_authenticate_user_by_id/2" do
      user = AccountFixtures.user_fixture()

      assert Api.maybe_authenticate_user_by_id("e986ed95-b46f-4ad5-8168-fdb575a623f6", "password") ==
               {:error, :no_user}

      assert Api.maybe_authenticate_user_by_id(user.id, "bad_password") == {:error, :bad_password}
      assert Api.maybe_authenticate_user_by_id(user.id, "password") == {:ok, user}
    end

    test "maybe_authenticate_user rate limit/2" do
      user = AccountFixtures.user_fixture()

      # No attempts so far, lets check for audit logs
      logs =
        Teiserver.Logging.list_audit_logs(
          where: [
            user_id: user.id
          ]
        )

      assert Enum.empty?(logs)

      # Bad login
      assert Api.maybe_authenticate_user_by_email(user.email, "bad_password", "my-ip") ==
               {:error, :bad_password}

      # Ensure it was logged
      [log] =
        Teiserver.Logging.list_audit_logs(
          where: [
            user_id: user.id
          ]
        )

      assert log.ip == "my-ip"
      assert log.details == %{"reason" => "bad_password"}
      assert log.action == "failed-login"
      assert log.user_id == user.id

      # Now do it a few more times to trip the breaker
      assert Api.maybe_authenticate_user_by_email(user.email, "bad_password", "my-ip") ==
               {:error, :bad_password}

      assert Api.maybe_authenticate_user_by_email(user.email, "bad_password", "my-ip") ==
               {:error, :bad_password}

      assert Api.maybe_authenticate_user_by_email(user.email, "bad_password", "my-ip") ==
               {:error, :bad_password}

      assert Api.maybe_authenticate_user_by_email(user.email, "bad_password", "my-ip") ==
               {:error, :rate_limit}
    end

    test "register_user/3" do
      # Incorrectly
      assert {:error, %Ecto.Changeset{} = _} = Api.register_user("alice", "email", "")

      # Correctly
      assert {:ok, %User{} = user} = Api.register_user("alice", "email", "password")
      assert user.permissions == []
      assert user.name == "alice"

      # Now dupe the email
      assert {:error, %Ecto.Changeset{} = _} = Api.register_user("alice", "email", "password")
    end

    test "connect_user/1" do
      user = AccountFixtures.user_fixture()
      conn = TestConn.new()

      client_ids = Teiserver.Connections.list_client_ids()
      refute Enum.member?(client_ids, user.id)

      assert TestConn.get(conn) == []
      TestConn.run(conn, fn -> Api.connect_user(user.id) end)

      # Check we're subbed to the right stuff
      PubSub.broadcast(
        Teiserver.PubSub,
        Teiserver.Connections.client_topic(user.id),
        "client_topic"
      )

      PubSub.broadcast(
        Teiserver.PubSub,
        Teiserver.Communication.user_messaging_topic(user.id),
        "user_messaging_topic"
      )

      assert TestConn.get(conn) == ["client_topic", "user_messaging_topic"]

      # Check we're counted as logged in
      client_ids = Teiserver.Connections.list_client_ids()
      assert Enum.member?(client_ids, user.id)
    end
  end

  # We just call these as they are for coverage purposes, they're delegated so tested fully elsewhere
  describe "delegates" do
    test "Communication" do
      room = CommunicationFixtures.room_fixture()
      user1 = AccountFixtures.user_fixture()
      user2 = AccountFixtures.user_fixture()

      assert room == Api.get_room_by_name_or_id(room.name)

      Api.subscribe_to_room_messages(room)
      Api.unsubscribe_from_room_messages(room)

      assert Api.list_recent_room_messages(room.id) == []

      {:ok, _} = Api.send_room_message(user1.id, room.id, "Content")
      {:ok, _} = Api.send_direct_message(user1.id, user2.id, "Content")
    end
  end
end
