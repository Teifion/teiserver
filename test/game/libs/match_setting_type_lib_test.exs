defmodule Teiserver.MatchSettingTypeLibTest do
  @moduledoc false
  alias Teiserver.Game.MatchSettingType
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

  describe "match_setting_type" do
    alias Teiserver.Game.MatchSettingType

    test "match_setting_type_query/0 returns a query" do
      q = Game.match_setting_type_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_setting_type/0 returns match_setting_type" do
      # No match_setting_type yet
      assert Game.list_match_setting_types([]) == []

      # Add a match_setting_type
      GameFixtures.match_setting_type_fixture()
      assert Game.list_match_setting_types([]) != []
    end

    test "get_or_create_match_setting_type/1 returns an id" do
      # No match_setting_type yet
      assert Game.list_match_setting_types([]) == []

      # Add a match_setting_type
      type_id = Game.get_or_create_match_setting_type("test-name")
      assert is_integer(type_id)
      [the_type] = Game.list_match_setting_types([])

      assert the_type.id == type_id
      assert the_type.name == "test-name"
    end

    test "get_match_setting_type!/1 and get_match_setting_type/1 returns the match_setting_type with given id" do
      match_setting_type = GameFixtures.match_setting_type_fixture()
      assert Game.get_match_setting_type!(match_setting_type.id) == match_setting_type
      assert Game.get_match_setting_type(match_setting_type.id) == match_setting_type
    end

    test "create_match_setting_type/1 with valid data creates a match_setting_type" do
      assert {:ok, %MatchSettingType{} = match_setting_type} =
               Game.create_match_setting_type(valid_attrs())

      assert match_setting_type.name == "some name"
    end

    test "create_match_setting_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_match_setting_type(invalid_attrs())
    end

    test "update_match_setting_type/2 with valid data updates the match_setting_type" do
      match_setting_type = GameFixtures.match_setting_type_fixture()

      assert {:ok, %MatchSettingType{} = match_setting_type} =
               Game.update_match_setting_type(match_setting_type, update_attrs())

      assert match_setting_type.name == "some updated name"
      assert match_setting_type.name == "some updated name"
    end

    test "update_match_setting_type/2 with invalid data returns error changeset" do
      match_setting_type = GameFixtures.match_setting_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_match_setting_type(match_setting_type, invalid_attrs())

      assert match_setting_type == Game.get_match_setting_type!(match_setting_type.id)
    end

    test "delete_match_setting_type/1 deletes the match_setting_type" do
      match_setting_type = GameFixtures.match_setting_type_fixture()
      assert {:ok, %MatchSettingType{}} = Game.delete_match_setting_type(match_setting_type)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_match_setting_type!(match_setting_type.id)
      end

      assert Game.get_match_setting_type(match_setting_type.id) == nil
    end

    test "change_match_setting_type/1 returns a match_setting_type changeset" do
      match_setting_type = GameFixtures.match_setting_type_fixture()
      assert %Ecto.Changeset{} = Game.change_match_setting_type(match_setting_type)
    end
  end
end
