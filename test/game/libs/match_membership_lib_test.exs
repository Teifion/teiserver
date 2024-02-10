defmodule Teiserver.MatchMembershipLibTest do
  @moduledoc false
  alias Teiserver.Game.MatchMembership
  alias Teiserver.Game
  use Teiserver.Case, async: true

  alias Teiserver.{GameFixtures, AccountFixtures}

  defp valid_attrs do
    %{
      match_id: GameFixtures.completed_match_fixture().id,
      user_id: AccountFixtures.user_fixture().id,
      team_number: 123,
      win?: true,
      party_id: "some party_id",
      left_after_seconds: 123
    }
  end

  defp update_attrs do
    %{
      match_id: GameFixtures.completed_match_fixture().id,
      user_id: AccountFixtures.user_fixture().id,
      team_number: 1234,
      win?: true,
      party_id: "some updated party_id",
      left_after_seconds: 1234
    }
  end

  defp invalid_attrs do
    %{
      match_id: nil,
      user_id: nil,
      team_number: nil,
      win?: nil,
      party_id: nil,
      left_after_seconds: nil
    }
  end

  describe "match_membership" do
    alias Teiserver.Game.MatchMembership

    test "match_membership_query/0 returns a query" do
      q = Game.match_membership_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_membership/0 returns match_membership" do
      # No match_membership yet
      assert Game.list_match_memberships([]) == []

      # Add a match_membership
      GameFixtures.match_membership_fixture()
      assert Game.list_match_memberships([]) != []
    end

    test "get_match_membership!/1 and get_match_membership/1 returns the match_membership with given id" do
      match_membership = GameFixtures.match_membership_fixture()

      assert Game.get_match_membership!(match_membership.match_id, match_membership.user_id) ==
               match_membership

      assert Game.get_match_membership(match_membership.match_id, match_membership.user_id) ==
               match_membership
    end

    test "create_match_membership/1 with valid data creates a match_membership" do
      assert {:ok, %MatchMembership{} = match_membership} =
               Game.create_match_membership(valid_attrs())

      assert match_membership.party_id == "some party_id"
    end

    test "create_match_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_match_membership(invalid_attrs())
    end

    test "create_many_match_memberships/1 with valid data creates a match_membership" do
      match = GameFixtures.incomplete_match_fixture()
      assert Enum.empty?(Game.list_match_memberships(where: [match_id: match.id]))

      attr_list = [
        %{match_id: match.id, user_id: AccountFixtures.user_fixture().id},
        %{match_id: match.id, user_id: AccountFixtures.user_fixture().id},
        %{match_id: match.id, user_id: AccountFixtures.user_fixture().id}
      ]

      # Now insert them
      assert {:ok, %{insert_all: {3, nil}}} = Game.create_many_match_memberships(attr_list)
      assert Enum.count(Game.list_match_memberships(where: [match_id: match.id])) == 3
    end

    test "create_many_match_memberships/1 with invalid data returns error" do
      match = GameFixtures.incomplete_match_fixture()
      assert Enum.empty?(Game.list_match_memberships(where: [match_id: match.id]))

      attr_list = [
        %{match_id: nil, user_id: AccountFixtures.user_fixture().id},
        %{match_id: nil, user_id: AccountFixtures.user_fixture().id},
        %{match_id: nil, user_id: AccountFixtures.user_fixture().id}
      ]

      # Now insert them
      assert_raise Postgrex.Error, fn -> Game.create_many_match_memberships(attr_list) end
      assert Enum.empty?(Game.list_match_memberships(where: [match_id: match.id]))
    end

    test "update_match_membership/2 with valid data updates the match_membership" do
      match_membership = GameFixtures.match_membership_fixture()

      assert {:ok, %MatchMembership{} = match_membership} =
               Game.update_match_membership(match_membership, update_attrs())

      assert match_membership.party_id == "some updated party_id"
      assert match_membership.party_id == "some updated party_id"
    end

    test "update_match_membership/2 with invalid data returns error changeset" do
      match_membership = GameFixtures.match_membership_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_match_membership(match_membership, invalid_attrs())

      assert match_membership ==
               Game.get_match_membership!(match_membership.match_id, match_membership.user_id)
    end

    test "delete_match_membership/1 deletes the match_membership" do
      match_membership = GameFixtures.match_membership_fixture()
      assert {:ok, %MatchMembership{}} = Game.delete_match_membership(match_membership)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_match_membership!(match_membership.match_id, match_membership.user_id)
      end

      assert Game.get_match_membership(match_membership.match_id, match_membership.user_id) == nil
    end

    test "change_match_membership/1 returns a match_membership changeset" do
      match_membership = GameFixtures.match_membership_fixture()
      assert %Ecto.Changeset{} = Game.change_match_membership(match_membership)
    end
  end
end
