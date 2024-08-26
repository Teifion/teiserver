defmodule Teiserver.UserSettingTest do
  @moduledoc false
  alias Teiserver.Settings.UserSetting
  use Teiserver.Case, async: false

  alias Teiserver.Settings
  alias Teiserver.Fixtures.{AccountFixtures, SettingsFixtures}

  defp valid_attrs do
    %{
      user_id: AccountFixtures.user_fixture().id,
      key: "some key",
      value: "true"
    }
  end

  defp update_attrs do
    %{
      user_id: AccountFixtures.user_fixture().id,
      key: "some updated key",
      value: "false"
    }
  end

  defp invalid_attrs do
    %{
      user_id: nil,
      key: nil,
      value: nil
    }
  end

  describe "user_setting" do
    alias Teiserver.Settings.UserSetting

    test "user_setting_query/0 returns a query" do
      q = Settings.user_setting_query([])
      assert %Ecto.Query{} = q
    end

    test "list_user_setting/0 returns user_setting" do
      # No user_setting yet
      assert Settings.list_user_settings([]) == []

      # Add a user_setting
      SettingsFixtures.user_setting_fixture()
      assert Settings.list_user_settings([]) != []
    end

    test "get_user_setting!/1 and get_user_setting/1 returns the user_setting with given id" do
      user_setting = SettingsFixtures.user_setting_fixture()
      assert Settings.get_user_setting!(user_setting.user_id, user_setting.key) == user_setting
      assert Settings.get_user_setting(user_setting.user_id, user_setting.key) == user_setting
    end

    test "create_user_setting/1 with valid data creates a user_setting" do
      assert {:ok, %UserSetting{} = user_setting} =
               Settings.create_user_setting(valid_attrs())

      assert user_setting.key == "some key"
    end

    test "create_user_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_user_setting(invalid_attrs())
    end

    test "update_user_setting/2 with valid data updates the user_setting" do
      user_setting = SettingsFixtures.user_setting_fixture()

      assert {:ok, %UserSetting{} = user_setting} =
               Settings.update_user_setting(user_setting, update_attrs())

      assert user_setting.key == "some updated key"
    end

    test "update_user_setting/2 with invalid data returns error changeset" do
      user_setting = SettingsFixtures.user_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Settings.update_user_setting(user_setting, invalid_attrs())

      assert user_setting == Settings.get_user_setting!(user_setting.user_id, user_setting.key)
    end

    test "delete_user_setting/1 deletes the user_setting" do
      user_setting = SettingsFixtures.user_setting_fixture()
      assert {:ok, %UserSetting{}} = Settings.delete_user_setting(user_setting)

      assert_raise Ecto.NoResultsError, fn ->
        Settings.get_user_setting!(user_setting.user_id, user_setting.key)
      end

      assert Settings.get_user_setting(user_setting.user_id, user_setting.key) == nil
    end

    test "change_user_setting/1 returns a user_setting changeset" do
      user_setting = SettingsFixtures.user_setting_fixture()
      assert %Ecto.Changeset{} = Settings.change_user_setting(user_setting)
    end
  end

  describe "values" do
    test "first insert" do
      user_id = AccountFixtures.user_fixture().id
      type = SettingsFixtures.user_setting_type_fixture()

      Settings.set_user_setting_value(user_id, type.key, "abcdef")
      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == "abcdef"

      Settings.set_user_setting_value(user_id, type.key, "123456")
      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == "123456"
    end

    test "strings" do
      user_id = AccountFixtures.user_fixture().id
      type = SettingsFixtures.user_setting_type_fixture(%{"type" => "string"})

      _setting =
        SettingsFixtures.user_setting_fixture(%{
          "user_id" => user_id,
          "type" => type,
          "value" => "123456789"
        })

      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == "123456789"

      Settings.set_user_setting_value(user_id, type.key, "abcdef")

      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == "abcdef"
    end

    test "integers" do
      user_id = AccountFixtures.user_fixture().id
      type = SettingsFixtures.user_setting_type_fixture(%{"type" => "integer"})

      _setting =
        SettingsFixtures.user_setting_fixture(%{
          "user_id" => user_id,
          "type" => type,
          "value" => "123456789"
        })

      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == 123_456_789

      Settings.set_user_setting_value(user_id, type.key, 123)

      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == 123
    end

    test "booleans" do
      user_id = AccountFixtures.user_fixture().id
      type = SettingsFixtures.user_setting_type_fixture(%{"type" => "boolean"})

      _setting =
        SettingsFixtures.user_setting_fixture(%{
          "user_id" => user_id,
          "type" => type,
          "value" => "t"
        })

      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == true

      Settings.set_user_setting_value(user_id, type.key, false)

      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == false

      # Set it back again as there are only two values
      Settings.set_user_setting_value(user_id, type.key, true)

      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == true
      assert Settings.get_user_setting_value(user_id, type.key) == value
    end

    test "validator function" do
      user_id = AccountFixtures.user_fixture().id

      type =
        SettingsFixtures.user_setting_type_fixture(%{
          "type" => "string",
          "validator" => fn v ->
            if String.length(v) > 6, do: :ok, else: {:error, "string too short"}
          end
        })

      _setting =
        SettingsFixtures.user_setting_fixture(%{
          "user_id" => user_id,
          "type" => type,
          "value" => "123456789"
        })

      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == "123456789"

      result = Settings.set_user_setting_value(user_id, type.key, "abcdef")
      assert result == {:error, "string too short"}

      value = Settings.get_user_setting_value(user_id, type.key)
      refute value == "abcdef"

      result = Settings.set_user_setting_value(user_id, type.key, "abcdefdef")
      assert result == :ok
      value = Settings.get_user_setting_value(user_id, type.key)
      assert value == "abcdefdef"
    end
  end
end
