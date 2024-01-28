defmodule Teiserver.RoomMessageLibTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Communication
  alias Teiserver.{CommunicationFixtures, AccountFixtures}

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
end
