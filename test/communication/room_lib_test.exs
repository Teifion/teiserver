defmodule Teiserver.RoomLibTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Communication.RoomLib
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

    test "list_room/0 returns room" do
      # No room yet
      assert RoomLib.list_rooms() == []
      assert RoomLib.list_rooms([]) == []

      # Add a room
      CommunicationFixtures.room_fixture()
      assert RoomLib.list_rooms() != []

      # Add a room
      assert RoomLib.list_rooms([]) != []
    end

    test "get_room!/1 and get_room/1 returns the room with given id" do
      room = CommunicationFixtures.room_fixture()
      assert RoomLib.get_room!(room.id) == room
      assert RoomLib.get_room(room.id) == room
    end

    test "get_room_by_X functions" do
      room1 = CommunicationFixtures.room_fixture()
      room2 = CommunicationFixtures.room_fixture()

      # Name
      assert RoomLib.get_room_by_name_or_id(room1.name) == room1
      assert RoomLib.get_room_by_name_or_id(room2.name) == room2

      # ID
      assert RoomLib.get_room_by_name_or_id(room1.id) == room1
      assert RoomLib.get_room_by_name_or_id(room2.id) == room2
    end

    test "create_room/1 with valid data creates a room" do
      assert {:ok, %Room{} = room} = RoomLib.create_room(@valid_attrs)
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RoomLib.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = CommunicationFixtures.room_fixture()
      assert {:ok, %Room{} = room} = RoomLib.update_room(room, @update_attrs)
      assert room.name == "some updated name"
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = CommunicationFixtures.room_fixture()
      assert {:error, %Ecto.Changeset{}} = RoomLib.update_room(room, @invalid_attrs)
      assert room == RoomLib.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = CommunicationFixtures.room_fixture()
      assert {:ok, %Room{}} = RoomLib.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> RoomLib.get_room!(room.id) end
      assert RoomLib.get_room(room.id) == nil
    end

    test "change_room/1 returns a room changeset" do
      room = CommunicationFixtures.room_fixture()
      assert %Ecto.Changeset{} = RoomLib.change_room(room)
    end
  end
end
