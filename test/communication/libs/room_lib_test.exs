defmodule Teiserver.RoomLibTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Communication
  alias Teiserver.CommunicationFixtures

  describe "room" do
    alias Teiserver.Communication.Room

    @valid_attrs %{
      name: "some name"
    }
    @update_attrs %{
      name: "some updated name"
    }
    @invalid_attrs %{
      name: nil
    }

    test "room_query/1 returns query" do
      assert Communication.room_query([])
    end

    test "list_room/0 returns rooms" do
      # No room yet
      assert Communication.list_rooms([]) == []

      # Add a room
      CommunicationFixtures.room_fixture()
      assert Communication.list_rooms([]) != []
    end

    test "get_room!/1 and get_room/1 returns the room with given id" do
      room = CommunicationFixtures.room_fixture()
      assert Communication.get_room!(room.id) == room
      assert Communication.get_room(room.id) == room
    end

    test "get_room_by_X functions" do
      room1 = CommunicationFixtures.room_fixture()
      room2 = CommunicationFixtures.room_fixture()

      # Name
      assert Communication.get_room_by_name_or_id(room1.name) == room1
      assert Communication.get_room_by_name_or_id(room2.name) == room2

      # ID
      assert Communication.get_room_by_name_or_id(room1.id) == room1
      assert Communication.get_room_by_name_or_id(room2.id) == room2
    end

    test "create_room/1 with valid data creates a room" do
      assert {:ok, %Room{} = room} = Communication.create_room(@valid_attrs)
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communication.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = CommunicationFixtures.room_fixture()
      assert {:ok, %Room{} = room} = Communication.update_room(room, @update_attrs)
      assert room.name == "some updated name"
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = CommunicationFixtures.room_fixture()
      assert {:error, %Ecto.Changeset{}} = Communication.update_room(room, @invalid_attrs)
      assert room == Communication.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = CommunicationFixtures.room_fixture()
      assert {:ok, %Room{}} = Communication.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Communication.get_room!(room.id) end
      assert Communication.get_room(room.id) == nil
    end

    test "change_room/1 returns a room changeset" do
      room = CommunicationFixtures.room_fixture()
      assert %Ecto.Changeset{} = Communication.change_room(room)
    end

    test "get_or_create_room/1" do
      room = CommunicationFixtures.room_fixture()
      assert Communication.get_or_create_room(room.name) == room

      new_room = Communication.get_or_create_room("MyMadeUpRoomName")
      assert %Room{} = new_room

      assert Communication.get_or_create_room("MyMadeUpRoomName") == new_room
    end

  end
end
