defmodule Teiserver.MatchTypeLibTest do
  @moduledoc false
  alias Teiserver.Game.MatchType
  alias Teiserver.Game
  use Teiserver.Case, async: true

  alias Teiserver.{GameFixtures}

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

  describe "match_type" do
    alias Teiserver.Game.MatchType

    test "match_type_query/0 returns a query" do
      q = Game.match_type_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_type/0 returns match_type" do
      # No match_type yet
      assert Game.list_match_types([]) == []

      # Add a match_type
      GameFixtures.match_type_fixture()
      assert Game.list_match_types([]) != []
    end

    test "get_or_create_match_type/1 returns an id" do
      # No match_type yet
      assert Game.list_match_types([]) == []

      # Add a match_type
      type = Game.get_or_create_match_type("test-name")
      assert %MatchType{} = type
      [the_type] = Game.list_match_types([])
      assert the_type == type

      assert the_type.name == "test-name"
    end

    test "get_match_type!/1 and get_match_type/1 returns the match_type with given id" do
      match_type = GameFixtures.match_type_fixture()
      assert Game.get_match_type!(match_type.id) == match_type
      assert Game.get_match_type(match_type.id) == match_type
    end

    test "create_match_type/1 with valid data creates a match_type" do
      assert {:ok, %MatchType{} = match_type} =
               Game.create_match_type(valid_attrs())

      assert match_type.name == "some name"
    end

    test "create_match_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_match_type(invalid_attrs())
    end

    test "update_match_type/2 with valid data updates the match_type" do
      match_type = GameFixtures.match_type_fixture()

      assert {:ok, %MatchType{} = match_type} =
               Game.update_match_type(match_type, update_attrs())

      assert match_type.name == "some updated name"
      assert match_type.name == "some updated name"
    end

    test "update_match_type/2 with invalid data returns error changeset" do
      match_type = GameFixtures.match_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_match_type(match_type, invalid_attrs())

      assert match_type == Game.get_match_type!(match_type.id)
    end

    test "delete_match_type/1 deletes the match_type" do
      match_type = GameFixtures.match_type_fixture()
      assert {:ok, %MatchType{}} = Game.delete_match_type(match_type)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_match_type!(match_type.id)
      end

      assert Game.get_match_type(match_type.id) == nil
    end

    test "change_match_type/1 returns a match_type changeset" do
      match_type = GameFixtures.match_type_fixture()
      assert %Ecto.Changeset{} = Game.change_match_type(match_type)
    end
  end
end
