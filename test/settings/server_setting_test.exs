defmodule Teiserver.ServerSettingTest do
  @moduledoc false
  alias Teiserver.Settings.ServerSetting
  use Teiserver.Case, async: false

  alias Teiserver.Settings
  alias Teiserver.Fixtures.SettingsFixtures

  defp valid_attrs do
    %{
      key: "some key",
      value: "true"
    }
  end

  defp update_attrs do
    %{
      key: "some updated key",
      value: "false"
    }
  end

  defp invalid_attrs do
    %{
      key: nil,
      value: nil
    }
  end

  describe "server_setting" do
    alias Teiserver.Settings.ServerSetting

    test "server_setting_query/0 returns a query" do
      q = Settings.server_setting_query([])
      assert %Ecto.Query{} = q
    end

    test "list_server_setting/0 returns server_setting" do
      # No server_setting yet
      assert Settings.list_server_settings([]) == []

      # Add a server_setting
      SettingsFixtures.server_setting_fixture()
      assert Settings.list_server_settings([]) != []
    end

    test "get_server_setting!/1 and get_server_setting/1 returns the server_setting with given id" do
      server_setting = SettingsFixtures.server_setting_fixture()
      assert Settings.get_server_setting!(server_setting.key) == server_setting
      assert Settings.get_server_setting(server_setting.key) == server_setting
    end

    test "create_server_setting/1 with valid data creates a server_setting" do
      assert {:ok, %ServerSetting{} = server_setting} =
               Settings.create_server_setting(valid_attrs())

      assert server_setting.key == "some key"
    end

    test "create_server_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_server_setting(invalid_attrs())
    end

    test "update_server_setting/2 with valid data updates the server_setting" do
      server_setting = SettingsFixtures.server_setting_fixture()

      assert {:ok, %ServerSetting{} = server_setting} =
               Settings.update_server_setting(server_setting, update_attrs())

      assert server_setting.key == "some updated key"
    end

    test "update_server_setting/2 with invalid data returns error changeset" do
      server_setting = SettingsFixtures.server_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Settings.update_server_setting(server_setting, invalid_attrs())

      assert server_setting == Settings.get_server_setting!(server_setting.key)
    end

    test "delete_server_setting/1 deletes the server_setting" do
      server_setting = SettingsFixtures.server_setting_fixture()
      assert {:ok, %ServerSetting{}} = Settings.delete_server_setting(server_setting)

      assert_raise Ecto.NoResultsError, fn ->
        Settings.get_server_setting!(server_setting.key)
      end

      assert Settings.get_server_setting(server_setting.key) == nil
    end

    test "change_server_setting/1 returns a server_setting changeset" do
      server_setting = SettingsFixtures.server_setting_fixture()
      assert %Ecto.Changeset{} = Settings.change_server_setting(server_setting)
    end
  end

  describe "values" do
    test "first insert" do
      type = SettingsFixtures.server_setting_type_fixture()

      Settings.set_server_setting_value(type.key, "abcdef")
      value = Settings.get_server_setting_value(type.key)
      assert value == "abcdef"

      Settings.set_server_setting_value(type.key, "123456")
      value = Settings.get_server_setting_value(type.key)
      assert value == "123456"
    end

    test "strings" do
      type = SettingsFixtures.server_setting_type_fixture(%{"type" => "string"})

      _setting =
        SettingsFixtures.server_setting_fixture(%{"type" => type, "value" => "123456789"})

      value = Settings.get_server_setting_value(type.key)
      assert value == "123456789"

      Settings.set_server_setting_value(type.key, "abcdef")

      value = Settings.get_server_setting_value(type.key)
      assert value == "abcdef"
    end

    test "integers" do
      type = SettingsFixtures.server_setting_type_fixture(%{"type" => "integer"})

      _setting =
        SettingsFixtures.server_setting_fixture(%{"type" => type, "value" => "123456789"})

      value = Settings.get_server_setting_value(type.key)
      assert value == 123_456_789

      Settings.set_server_setting_value(type.key, 123)

      value = Settings.get_server_setting_value(type.key)
      assert value == 123
    end

    test "booleans" do
      type = SettingsFixtures.server_setting_type_fixture(%{"type" => "boolean"})
      _setting = SettingsFixtures.server_setting_fixture(%{"type" => type, "value" => "t"})

      value = Settings.get_server_setting_value(type.key)
      assert value == true

      Settings.set_server_setting_value(type.key, false)

      value = Settings.get_server_setting_value(type.key)
      assert value == false

      # Set it back again as there are only two values
      Settings.set_server_setting_value(type.key, true)

      value = Settings.get_server_setting_value(type.key)
      assert value == true
    end
  end
end
