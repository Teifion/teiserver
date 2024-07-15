defmodule Teiserver.UserChoiceTypeLibTest do
  @moduledoc false
  alias Teiserver.Game.UserChoiceType
  alias Teiserver.Game
  use Teiserver.Case, async: true

  alias Teiserver.Fixtures.{GameFixtures}

  defp valid_attrs do
    %{
      name: "some name"
    }
  end

  defp update_attrs do
    %{
      name: "some updated name"
    }
  end

  defp invalid_attrs do
    %{
      name: nil
    }
  end

  describe "user_choice_type" do
    alias Teiserver.Game.UserChoiceType

    test "user_choice_type_query/0 returns a query" do
      q = Game.user_choice_type_query([])
      assert %Ecto.Query{} = q
    end

    test "list_user_choice_type/0 returns user_choice_type" do
      # No user_choice_type yet
      assert Game.list_user_choice_types([]) == []

      # Add a user_choice_type
      GameFixtures.user_choice_type_fixture()
      assert Game.list_user_choice_types([]) != []
    end

    test "get_or_create_user_choice_type_id/1 returns an id" do
      # No user_choice_type yet
      assert Game.list_user_choice_types([]) == []

      # Add a user_choice_type
      type_id = Game.get_or_create_user_choice_type_id("test-name")
      assert is_integer(type_id)
      [the_type] = Game.list_user_choice_types([])

      assert the_type.id == type_id
      assert the_type.name == "test-name"
    end

    test "get_user_choice_type!/1 and get_user_choice_type/1 returns the user_choice_type with given id" do
      user_choice_type = GameFixtures.user_choice_type_fixture()
      assert Game.get_user_choice_type!(user_choice_type.id) == user_choice_type
      assert Game.get_user_choice_type(user_choice_type.id) == user_choice_type
    end

    test "create_user_choice_type/1 with valid data creates a user_choice_type" do
      assert {:ok, %UserChoiceType{} = user_choice_type} =
               Game.create_user_choice_type(valid_attrs())

      assert user_choice_type.name == "some name"
    end

    test "create_user_choice_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_user_choice_type(invalid_attrs())
    end

    test "update_user_choice_type/2 with valid data updates the user_choice_type" do
      user_choice_type = GameFixtures.user_choice_type_fixture()

      assert {:ok, %UserChoiceType{} = user_choice_type} =
               Game.update_user_choice_type(user_choice_type, update_attrs())

      assert user_choice_type.name == "some updated name"
      assert user_choice_type.name == "some updated name"
    end

    test "update_user_choice_type/2 with invalid data returns error changeset" do
      user_choice_type = GameFixtures.user_choice_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_user_choice_type(user_choice_type, invalid_attrs())

      assert user_choice_type == Game.get_user_choice_type!(user_choice_type.id)
    end

    test "delete_user_choice_type/1 deletes the user_choice_type" do
      user_choice_type = GameFixtures.user_choice_type_fixture()
      assert {:ok, %UserChoiceType{}} = Game.delete_user_choice_type(user_choice_type)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_user_choice_type!(user_choice_type.id)
      end

      assert Game.get_user_choice_type(user_choice_type.id) == nil
    end

    test "change_user_choice_type/1 returns a user_choice_type changeset" do
      user_choice_type = GameFixtures.user_choice_type_fixture()
      assert %Ecto.Changeset{} = Game.change_user_choice_type(user_choice_type)
    end
  end
end
