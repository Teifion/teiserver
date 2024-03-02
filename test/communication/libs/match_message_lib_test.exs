defmodule Teiserver.MatchMessageLibTest do
  @moduledoc false
  alias Teiserver.Communication.MatchMessage
  use Teiserver.Case, async: true

  alias Teiserver.Communication
  alias Teiserver.{CommunicationFixtures, AccountFixtures, ConnectionFixtures, GameFixtures}

  defp valid_attrs do
    %{
      content: "some content",
      inserted_at: Timex.now(),
      sender_id: AccountFixtures.user_fixture().id,
      match_id: GameFixtures.incomplete_match_fixture().id
    }
  end

  defp update_attrs do
    %{
      content: "some updated content",
      inserted_at: Timex.now(),
      sender_id: AccountFixtures.user_fixture().id,
      match_id: GameFixtures.incomplete_match_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      content: nil,
      inserted_at: nil,
      sender_id: nil,
      match_id: nil
    }
  end

  describe "match_message" do
    alias Teiserver.Communication.MatchMessage

    test "match_message_query/1 returns query" do
      assert Communication.match_message_query([])
    end

    test "list_match_message/0 returns match_message" do
      # No match_message yet
      assert Communication.list_match_messages([]) == []

      # Add a match_message
      m = CommunicationFixtures.match_message_fixture()
      assert Communication.list_match_messages([]) != []

      # Assert recent lists those too
      assert Communication.list_match_messages([]) ==
               Communication.list_recent_match_messages(m.match_id)
    end

    test "get_match_message!/1 and get_match_message/1 returns the match_message with given id" do
      match_message = CommunicationFixtures.match_message_fixture()
      assert Communication.get_match_message!(match_message.id) == match_message
      assert Communication.get_match_message(match_message.id) == match_message
    end

    test "create_match_message/1 with valid data creates a match_message" do
      assert {:ok, %MatchMessage{} = match_message} =
               Communication.create_match_message(valid_attrs())

      assert match_message.content == "some content"
    end

    test "create_match_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communication.create_match_message(invalid_attrs())
    end

    test "update_match_message/2 with valid data updates the match_message" do
      match_message = CommunicationFixtures.match_message_fixture()

      assert {:ok, %MatchMessage{} = match_message} =
               Communication.update_match_message(match_message, update_attrs())

      assert match_message.content == "some updated content"
      assert match_message.content == "some updated content"
    end

    test "update_match_message/2 with invalid data returns error changeset" do
      match_message = CommunicationFixtures.match_message_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Communication.update_match_message(match_message, invalid_attrs())

      assert match_message == Communication.get_match_message!(match_message.id)
    end

    test "delete_match_message/1 deletes the match_message" do
      match_message = CommunicationFixtures.match_message_fixture()
      assert {:ok, %MatchMessage{}} = Communication.delete_match_message(match_message)

      assert_raise Ecto.NoResultsError, fn ->
        Communication.get_match_message!(match_message.id)
      end

      assert Communication.get_match_message(match_message.id) == nil
    end

    test "change_match_message/1 returns a match_message changeset" do
      match_message = CommunicationFixtures.match_message_fixture()
      assert %Ecto.Changeset{} = Communication.change_match_message(match_message)
    end
  end

  describe "messaging" do
    test "match" do
      {conn1, user1} = ConnectionFixtures.client_fixture()
      {conn2, user2} = ConnectionFixtures.client_fixture()
      {conn3, user3} = ConnectionFixtures.client_fixture()

      match = GameFixtures.unstarted_match_fixture()
      topic = Communication.match_messaging_topic(match.id)

      TestConn.run(conn1, fn -> Communication.subscribe_to_match_messages(match.id) end)
      TestConn.run(conn2, fn -> Communication.subscribe_to_match_messages(match.id) end)
      TestConn.run(conn3, fn -> Communication.subscribe_to_match_messages(match.id) end)

      assert TestConn.get(conn1) == []
      assert TestConn.get(conn2) == []
      assert TestConn.get(conn3) == []

      # Now send messages
      Communication.send_match_message(user1.id, match.id, "Test first message")

      # Need to alias these here for the match
      user1_id = user1.id
      user2_id = user2.id
      user3_id = user3.id
      match_id = match.id

      [conn1, conn2, conn3]
      |> Enum.each(fn c ->
        [message] = TestConn.get(c)

        assert match?(
                 %{
                   event: :message_received,
                   topic: ^topic,
                   match_message: %MatchMessage{
                     id: _,
                     content: "Test first message",
                     sender_id: ^user1_id,
                     match_id: ^match_id
                   }
                 },
                 message
               )
      end)

      # If we send three more, they should all appear but the first should now be removed
      Communication.send_match_message(user1.id, match.id, "Test second message")
      Communication.send_match_message(user2.id, match.id, "Test third message")
      Communication.send_match_message(user3.id, match.id, "Test fourth message")

      [conn1, conn2, conn3]
      |> Enum.each(fn c ->
        [m1, m2, m3] = TestConn.get(c)

        assert match?(
                 %{
                   event: :message_received,
                   topic: ^topic,
                   match_message: %MatchMessage{
                     id: _,
                     content: "Test second message",
                     sender_id: ^user1_id,
                     match_id: ^match_id
                   }
                 },
                 m1
               )

        assert match?(
                 %{
                   event: :message_received,
                   topic: ^topic,
                   match_message: %MatchMessage{
                     id: _,
                     content: "Test third message",
                     sender_id: ^user2_id,
                     match_id: ^match_id
                   }
                 },
                 m2
               )

        assert match?(
                 %{
                   event: :message_received,
                   topic: ^topic,
                   match_message: %MatchMessage{
                     id: _,
                     content: "Test fourth message",
                     sender_id: ^user3_id,
                     match_id: ^match_id
                   }
                 },
                 m3
               )
      end)

      # Now assert it errors the correct way
      {:error, changeset} = Communication.send_match_message(nil, match.id, "Test second message")
      assert %Ecto.Changeset{valid?: false} = changeset

      # Unsub
      TestConn.run(conn1, fn -> Communication.unsubscribe_from_match_messages(match.id) end)
      TestConn.run(conn2, fn -> Communication.unsubscribe_from_match_messages(match.id) end)
      TestConn.run(conn3, fn -> Communication.unsubscribe_from_match_messages(match.id) end)

      Communication.send_match_message(user1.id, match.id, "This message should not be seen")

      [conn1, conn2, conn3]
      |> Enum.each(fn c ->
        assert TestConn.get(c) == []
      end)
    end
  end
end
