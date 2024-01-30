defmodule Teiserver.RoomMessageLibTest do
  @moduledoc false
  alias Teiserver.Communication.RoomMessage
  use Teiserver.Case, async: true

  alias Teiserver.Communication
  alias Teiserver.{CommunicationFixtures, AccountFixtures, ConnectionFixtures}

  defp valid_attrs() do
    %{
      content: "some content",
      inserted_at: Timex.now(),
      sender_id: AccountFixtures.user_fixture().id,
      room_id: CommunicationFixtures.room_fixture().id
    }
  end

  defp update_attrs() do
    %{
      content: "some updated content",
      inserted_at: Timex.now(),
      sender_id: AccountFixtures.user_fixture().id,
      room_id: CommunicationFixtures.room_fixture().id
    }
  end

  defp invalid_attrs() do
    %{
      content: nil,
      inserted_at: nil,
      sender_id: nil,
      room_id: nil
    }
  end

  describe "room_message" do
    alias Teiserver.Communication.RoomMessage

    test "room_message_query/1 returns query" do
      assert Communication.room_message_query([])
    end

    test "list_room_message/0 returns room_message" do
      # No room_message yet
      assert Communication.list_room_messages([]) == []

      # Add a room_message
      CommunicationFixtures.room_message_fixture()
      assert Communication.list_room_messages([]) != []
    end

    test "get_room_message!/1 and get_room_message/1 returns the room_message with given id" do
      room_message = CommunicationFixtures.room_message_fixture()
      assert Communication.get_room_message!(room_message.id) == room_message
      assert Communication.get_room_message(room_message.id) == room_message
    end

    test "create_room_message/1 with valid data creates a room_message" do
      assert {:ok, %RoomMessage{} = room_message} =
               Communication.create_room_message(valid_attrs())

      assert room_message.content == "some content"
    end

    test "create_room_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communication.create_room_message(invalid_attrs())
    end

    test "update_room_message/2 with valid data updates the room_message" do
      room_message = CommunicationFixtures.room_message_fixture()

      assert {:ok, %RoomMessage{} = room_message} =
               Communication.update_room_message(room_message, update_attrs())

      assert room_message.content == "some updated content"
      assert room_message.content == "some updated content"
    end

    test "update_room_message/2 with invalid data returns error changeset" do
      room_message = CommunicationFixtures.room_message_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Communication.update_room_message(room_message, invalid_attrs())

      assert room_message == Communication.get_room_message!(room_message.id)
    end

    test "delete_room_message/1 deletes the room_message" do
      room_message = CommunicationFixtures.room_message_fixture()
      assert {:ok, %RoomMessage{}} = Communication.delete_room_message(room_message)

      assert_raise Ecto.NoResultsError, fn ->
        Communication.get_room_message!(room_message.id)
      end

      assert Communication.get_room_message(room_message.id) == nil
    end

    test "change_room_message/1 returns a room_message changeset" do
      room_message = CommunicationFixtures.room_message_fixture()
      assert %Ecto.Changeset{} = Communication.change_room_message(room_message)
    end
  end

  describe "messaging" do
    test "room" do
      r = :rand.uniform(999_999_999)
      {conn1, user1} = ConnectionFixtures.client_fixture()
      {conn2, user2} = ConnectionFixtures.client_fixture()
      {conn3, user3} = ConnectionFixtures.client_fixture()

      room = Communication.get_or_create_room("#{r}_messaging_room")
      topic = Communication.room_topic(room.id)

      TestConn.run(conn1, fn -> Communication.subscribe_to_room(room.id) end)
      TestConn.run(conn2, fn -> Communication.subscribe_to_room(room.id) end)
      TestConn.run(conn3, fn -> Communication.subscribe_to_room(room.id) end)

      assert TestConn.get(conn1) == []
      assert TestConn.get(conn2) == []
      assert TestConn.get(conn3) == []

      # Now send messages
      Communication.send_room_message(user1.id, room.id, "Test first message")

      # Need to alias these here for the match
      user1_id = user1.id
      user2_id = user2.id
      user3_id = user3.id
      room_id = room.id

      [conn1, conn2, conn3]
      |> Enum.each(fn c ->
        [message] = TestConn.get(c)

        assert match?(
                 %{
                   event: :message_received,
                   topic: ^topic,
                   room_message: %RoomMessage{
                     id: _,
                     content: "Test first message",
                     sender_id: ^user1_id,
                     room_id: ^room_id
                   }
                 },
                 message
               )
      end)

      # If we send three more, they should all appear but the first should now be removed
      Communication.send_room_message(user1.id, room.id, "Test second message")
      Communication.send_room_message(user2.id, room.id, "Test third message")
      Communication.send_room_message(user3.id, room.id, "Test fourth message")

      [conn1, conn2, conn3]
      |> Enum.each(fn c ->
        [m1, m2, m3] = TestConn.get(c)

        assert match?(
                 %{
                   event: :message_received,
                   topic: ^topic,
                   room_message: %RoomMessage{
                     id: _,
                     content: "Test second message",
                     sender_id: ^user1_id,
                     room_id: ^room_id
                   }
                 },
                 m1
               )

        assert match?(
                 %{
                   event: :message_received,
                   topic: ^topic,
                   room_message: %RoomMessage{
                     id: _,
                     content: "Test third message",
                     sender_id: ^user2_id,
                     room_id: ^room_id
                   }
                 },
                 m2
               )

        assert match?(
                 %{
                   event: :message_received,
                   topic: ^topic,
                   room_message: %RoomMessage{
                     id: _,
                     content: "Test fourth message",
                     sender_id: ^user3_id,
                     room_id: ^room_id
                   }
                 },
                 m3
               )
      end)
    end
  end
end
