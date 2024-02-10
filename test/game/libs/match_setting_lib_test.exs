defmodule Teiserver.MatchSettingLibTest do
  @moduledoc false
  alias Teiserver.Game.MatchSetting
  alias Teiserver.Game
  use Teiserver.Case, async: true

  alias Teiserver.{GameFixtures}

  defp valid_attrs do
    %{
      match_id: GameFixtures.completed_match_fixture().id,
      type_id: GameFixtures.match_setting_type_fixture().id,
      value: "some value"
    }
  end

  defp update_attrs do
    %{
      match_id: GameFixtures.completed_match_fixture().id,
      type_id: GameFixtures.match_setting_type_fixture().id,
      value: "some updated value"
    }
  end

  defp invalid_attrs do
    %{
      match_id: nil,
      type_id: nil,
      value: nil
    }
  end

  describe "match_setting" do
    alias Teiserver.Game.MatchSetting

    test "match_setting_query/0 returns a query" do
      q = Game.match_setting_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match_setting/0 returns match_setting" do
      # No match_setting yet
      assert Game.list_match_settings([]) == []

      # Add a match_setting
      GameFixtures.match_setting_fixture()
      assert Game.list_match_settings([]) != []
    end

    test "get_match_setting!/1 and get_match_setting/1 returns the match_setting with given id" do
      match_setting = GameFixtures.match_setting_fixture()

      assert Game.get_match_setting!(match_setting.match_id, match_setting.type_id) ==
               match_setting

      assert Game.get_match_setting(match_setting.match_id, match_setting.type_id) ==
               match_setting
    end

    test "create_match_setting/1 with valid data creates a match_setting" do
      assert {:ok, %MatchSetting{} = match_setting} =
               Game.create_match_setting(valid_attrs())

      assert match_setting.value == "some value"
    end

    test "create_match_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_match_setting(invalid_attrs())
    end

    test "create_many_match_settings/1 with valid data creates a match_setting" do
      match = GameFixtures.incomplete_match_fixture()
      assert Enum.empty?(Game.list_match_settings(where: [match_id: match.id]))

      attr_list = [
        %{match_id: match.id, type_id: GameFixtures.match_setting_type_fixture().id},
        %{match_id: match.id, type_id: GameFixtures.match_setting_type_fixture().id},
        %{match_id: match.id, type_id: GameFixtures.match_setting_type_fixture().id}
      ]

      # Now insert them
      assert {:ok, %{insert_all: {3, nil}}} = Game.create_many_match_settings(attr_list)
      assert Enum.count(Game.list_match_settings(where: [match_id: match.id])) == 3
    end

    test "create_many_match_settings/1 with invalid data returns error" do
      match = GameFixtures.incomplete_match_fixture()
      assert Enum.empty?(Game.list_match_settings(where: [match_id: match.id]))

      attr_list = [
        %{match_id: nil, type_id: GameFixtures.match_setting_type_fixture().id},
        %{match_id: nil, type_id: GameFixtures.match_setting_type_fixture().id},
        %{match_id: nil, type_id: GameFixtures.match_setting_type_fixture().id}
      ]

      # Now insert them
      assert_raise Postgrex.Error, fn -> Game.create_many_match_settings(attr_list) end
      assert Enum.empty?(Game.list_match_settings(where: [match_id: match.id]))
    end

    test "update_match_setting/2 with valid data updates the match_setting" do
      match_setting = GameFixtures.match_setting_fixture()

      assert {:ok, %MatchSetting{} = match_setting} =
               Game.update_match_setting(match_setting, update_attrs())

      assert match_setting.value == "some updated value"
      assert match_setting.value == "some updated value"
    end

    test "update_match_setting/2 with invalid data returns error changeset" do
      match_setting = GameFixtures.match_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_match_setting(match_setting, invalid_attrs())

      assert match_setting ==
               Game.get_match_setting!(match_setting.match_id, match_setting.type_id)
    end

    test "delete_match_setting/1 deletes the match_setting" do
      match_setting = GameFixtures.match_setting_fixture()
      assert {:ok, %MatchSetting{}} = Game.delete_match_setting(match_setting)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_match_setting!(match_setting.match_id, match_setting.type_id)
      end

      assert Game.get_match_setting(match_setting.match_id, match_setting.type_id) == nil
    end

    test "change_match_setting/1 returns a match_setting changeset" do
      match_setting = GameFixtures.match_setting_fixture()
      assert %Ecto.Changeset{} = Game.change_match_setting(match_setting)
    end
  end
end
