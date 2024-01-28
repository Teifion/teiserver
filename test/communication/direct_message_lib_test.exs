defmodule Teiserver.DirectMessageLibTest do
  @moduledoc false
  alias Teiserver.Communication
  use Teiserver.Case, async: true

  alias Teiserver.Communication
  alias Teiserver.{CommunicationFixtures, AccountFixtures}

  defp valid_attrs() do
    %{
      content: "some content",
      inserted_at: Timex.now(),
      from_id: AccountFixtures.user_fixture().id,
      to_id: AccountFixtures.user_fixture().id
    }
  end

  defp update_attrs() do
    %{
      content: "some updated content",
      inserted_at: Timex.now(),
      from_id: AccountFixtures.user_fixture().id,
      to_id: AccountFixtures.user_fixture().id
    }
  end

  defp invalid_attrs() do
    %{
      content: nil,
      inserted_at: nil,
      from_id: nil,
      to_id: nil
    }
  end

  describe "direct_message" do
    alias Teiserver.Communication.DirectMessage

    test "direct_message_query/0 returns a query" do
      q = Communication.direct_message_query([])
      assert %Ecto.Query{} = q
    end

    test "list_direct_message/0 returns direct_message" do
      # No direct_message yet
      assert Communication.list_direct_messages([]) == []

      # Add a direct_message
      CommunicationFixtures.direct_message_fixture()
      assert Communication.list_direct_messages([]) != []
    end

    test "list_direct_messages_for_user/1" do
      user1 = AccountFixtures.user_fixture()

      # No direct_message yet
      assert Communication.list_direct_messages_for_user(user1.id) == []

      # Add a direct_message
      m1 = CommunicationFixtures.direct_message_fixture(to_id: user1.id)
      m2 = CommunicationFixtures.direct_message_fixture(from_id: user1.id)
      _m3 = CommunicationFixtures.direct_message_fixture()
      assert Communication.list_direct_messages_for_user(user1.id) == [m1, m2]
    end

    test "list_direct_messages_to_user/1" do
      user1 = AccountFixtures.user_fixture()

      # No direct_message yet
      assert Communication.list_direct_messages_to_user(user1.id) == []

      # Add a direct_message
      m1 = CommunicationFixtures.direct_message_fixture(to_id: user1.id)
      _m2 = CommunicationFixtures.direct_message_fixture(from_id: user1.id)
      _m3 = CommunicationFixtures.direct_message_fixture()
      assert Communication.list_direct_messages_to_user(user1.id) == [m1]
    end

    test "list_direct_messages_from_user/1" do
      user1 = AccountFixtures.user_fixture()

      # No direct_message yet
      assert Communication.list_direct_messages_from_user(user1.id) == []

      # Add a direct_message
      _m1 = CommunicationFixtures.direct_message_fixture(to_id: user1.id)
      m2 = CommunicationFixtures.direct_message_fixture(from_id: user1.id)
      _m3 = CommunicationFixtures.direct_message_fixture()
      assert Communication.list_direct_messages_from_user(user1.id) == [m2]
    end

    test "list_direct_messages_from_user_to_user/1" do
      user1 = AccountFixtures.user_fixture()
      user2 = AccountFixtures.user_fixture()

      # No direct_message yet
      assert Communication.list_direct_messages_from_user_to_user(user1.id, user2.id) == []

      # Add a direct_message
      _m1 = CommunicationFixtures.direct_message_fixture(to_id: user1.id)
      _m2 = CommunicationFixtures.direct_message_fixture(from_id: user1.id)
      _m3 = CommunicationFixtures.direct_message_fixture()
      m4 = CommunicationFixtures.direct_message_fixture(from_id: user1.id, to_id: user2.id)
      _m5 = CommunicationFixtures.direct_message_fixture(from_id: user2.id, to_id: user1.id)
      assert Communication.list_direct_messages_from_user_to_user(user1.id, user2.id) == [m4]
    end

    test "list_direct_messages_between_users/1" do
      user1 = AccountFixtures.user_fixture()
      user2 = AccountFixtures.user_fixture()

      # No direct_message yet
      assert Communication.list_direct_messages_between_users(user1.id, user2.id) == []

      # Add a direct_message
      _m1 = CommunicationFixtures.direct_message_fixture(to_id: user1.id)
      _m2 = CommunicationFixtures.direct_message_fixture(from_id: user1.id)
      _m3 = CommunicationFixtures.direct_message_fixture()
      m4 = CommunicationFixtures.direct_message_fixture(from_id: user1.id, to_id: user2.id)
      m5 = CommunicationFixtures.direct_message_fixture(from_id: user2.id, to_id: user1.id)
      assert Communication.list_direct_messages_between_users(user1.id, user2.id) == [m4, m5]
    end

    test "get_direct_message!/1 and get_direct_message/1 returns the direct_message with given id" do
      direct_message = CommunicationFixtures.direct_message_fixture()
      assert Communication.get_direct_message!(direct_message.id) == direct_message
      assert Communication.get_direct_message(direct_message.id) == direct_message
    end

    test "create_direct_message/1 with valid data creates a direct_message" do
      assert {:ok, %DirectMessage{} = direct_message} =
               Communication.create_direct_message(valid_attrs())

      assert direct_message.content == "some content"
    end

    test "create_direct_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communication.create_direct_message(invalid_attrs())
    end

    test "update_direct_message/2 with valid data updates the direct_message" do
      direct_message = CommunicationFixtures.direct_message_fixture()

      assert {:ok, %DirectMessage{} = direct_message} =
               Communication.update_direct_message(direct_message, update_attrs())

      assert direct_message.content == "some updated content"
      assert direct_message.content == "some updated content"
    end

    test "update_direct_message/2 with invalid data returns error changeset" do
      direct_message = CommunicationFixtures.direct_message_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Communication.update_direct_message(direct_message, invalid_attrs())

      assert direct_message == Communication.get_direct_message!(direct_message.id)
    end

    test "delete_direct_message/1 deletes the direct_message" do
      direct_message = CommunicationFixtures.direct_message_fixture()
      assert {:ok, %DirectMessage{}} = Communication.delete_direct_message(direct_message)

      assert_raise Ecto.NoResultsError, fn ->
        Communication.get_direct_message!(direct_message.id)
      end

      assert Communication.get_direct_message(direct_message.id) == nil
    end

    test "change_direct_message/1 returns a direct_message changeset" do
      direct_message = CommunicationFixtures.direct_message_fixture()
      assert %Ecto.Changeset{} = Communication.change_direct_message(direct_message)
    end
  end
end
