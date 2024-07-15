defmodule Teiserver.UserChoiceLibTest do
  @moduledoc false
  alias Teiserver.Game.UserChoice
  alias Teiserver.Game
  use Teiserver.Case, async: true

  alias Teiserver.Fixtures.{AccountFixtures, GameFixtures}

  defp valid_attrs do
    %{
      match_id: GameFixtures.completed_match_fixture().id,
      type_id: GameFixtures.user_choice_type_fixture().id,
      user_id: AccountFixtures.user_fixture().id,
      value: "some value"
    }
  end

  defp update_attrs do
    %{
      match_id: GameFixtures.completed_match_fixture().id,
      type_id: GameFixtures.user_choice_type_fixture().id,
      user_id: AccountFixtures.user_fixture().id,
      value: "some updated value"
    }
  end

  defp invalid_attrs do
    %{
      match_id: nil,
      type_id: nil,
      user_id: nil,
      value: nil
    }
  end

  describe "user_choice" do
    alias Teiserver.Game.UserChoice

    test "user_choice_query/0 returns a query" do
      q = Game.user_choice_query([])
      assert %Ecto.Query{} = q
    end

    test "list_user_choice/0 returns user_choice" do
      # No user_choice yet
      assert Game.list_user_choices([]) == []

      # Add a user_choice
      GameFixtures.user_choice_fixture()
      assert Game.list_user_choices([]) != []
    end

    test "get_user_choice!/1 and get_user_choice/1 returns the user_choice with given id" do
      user_choice = GameFixtures.user_choice_fixture()

      assert Game.get_user_choice!(user_choice.match_id, user_choice.user_id, user_choice.type_id) ==
               user_choice

      assert Game.get_user_choice(user_choice.match_id, user_choice.user_id, user_choice.type_id) ==
               user_choice
    end

    test "get_user_choices_map/2" do
      user = AccountFixtures.user_fixture()
      match = GameFixtures.incomplete_match_fixture()

      user_choice1 = GameFixtures.user_choice_fixture(%{user_id: user.id, match_id: match.id})
      user_choice2 = GameFixtures.user_choice_fixture(%{user_id: user.id, match_id: match.id})
      user_choice3 = GameFixtures.user_choice_fixture(%{match_id: match.id})
      user_choice4 = GameFixtures.user_choice_fixture(%{user_id: user.id})

      values = Game.get_user_choices_map(match.id, user.id) |> Map.values

      assert Enum.member?(values, user_choice1.value)
      assert Enum.member?(values, user_choice2.value)
      refute Enum.member?(values, user_choice3.value)
      refute Enum.member?(values, user_choice4.value)
    end

    test "create_user_choice/1 with valid data creates a user_choice" do
      assert {:ok, %UserChoice{} = user_choice} =
               Game.create_user_choice(valid_attrs())

      assert user_choice.value == "some value"
    end

    test "create_user_choice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_user_choice(invalid_attrs())
    end

    test "create_many_user_choices/1 with valid data creates a user_choice" do
      match = GameFixtures.incomplete_match_fixture()
      user = AccountFixtures.user_fixture()
      assert Enum.empty?(Game.list_user_choices(where: [match_id: match.id, user_id: user.id]))

      attr_list = [
        %{match_id: match.id, type_id: GameFixtures.user_choice_type_fixture().id, user_id: user.id},
        %{match_id: match.id, type_id: GameFixtures.user_choice_type_fixture().id, user_id: user.id},
        %{match_id: match.id, type_id: GameFixtures.user_choice_type_fixture().id, user_id: user.id}
      ]

      # Now insert them
      assert {:ok, %{insert_all: {3, nil}}} = Game.create_many_user_choices(attr_list)
      assert Enum.count(Game.list_user_choices(where: [match_id: match.id, user_id: user.id])) == 3
    end

    test "create_many_user_choices/1 with invalid data returns error" do
      match = GameFixtures.incomplete_match_fixture()
      user = AccountFixtures.user_fixture()
      assert Enum.empty?(Game.list_user_choices(where: [match_id: match.id, user_id: user.id]))

      attr_list = [
        %{match_id: nil, type_id: GameFixtures.user_choice_type_fixture().id, user_id: AccountFixtures.user_fixture().id},
        %{match_id: nil, type_id: GameFixtures.user_choice_type_fixture().id, user_id: AccountFixtures.user_fixture().id},
        %{match_id: nil, type_id: GameFixtures.user_choice_type_fixture().id, user_id: AccountFixtures.user_fixture().id}
      ]

      # Now insert them
      assert_raise Postgrex.Error, fn -> Game.create_many_user_choices(attr_list) end
      assert Enum.empty?(Game.list_user_choices(where: [match_id: match.id, user_id: user.id]))
    end

    test "update_user_choice/2 with valid data updates the user_choice" do
      user_choice = GameFixtures.user_choice_fixture()

      assert {:ok, %UserChoice{} = user_choice} =
               Game.update_user_choice(user_choice, update_attrs())

      assert user_choice.value == "some updated value"
    end

    test "update_user_choice/2 with invalid data returns error changeset" do
      user_choice = GameFixtures.user_choice_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_user_choice(user_choice, invalid_attrs())

      assert user_choice ==
               Game.get_user_choice!(user_choice.match_id, user_choice.user_id, user_choice.type_id)
    end

    test "delete_user_choice/1 deletes the user_choice" do
      user_choice = GameFixtures.user_choice_fixture()
      assert {:ok, %UserChoice{}} = Game.delete_user_choice(user_choice)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_user_choice!(user_choice.match_id, user_choice.user_id, user_choice.type_id)
      end

      assert Game.get_user_choice(user_choice.match_id, user_choice.user_id, user_choice.type_id) == nil
    end

    test "change_user_choice/1 returns a user_choice changeset" do
      user_choice = GameFixtures.user_choice_fixture()
      assert %Ecto.Changeset{} = Game.change_user_choice(user_choice)
    end
  end
end
