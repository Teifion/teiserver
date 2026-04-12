defmodule Teiserver.ServerSettingTypeTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Settings

  describe "server setting types" do
    test "create - errors" do
      assert_raise(KeyError, fn ->
        Settings.add_server_setting_type(%{
          key: "#{__MODULE__} create errors"
        })
      end)

      assert_raise(KeyError, fn ->
        Settings.add_server_setting_type(%{
          key: "#{__MODULE__} create errors",
          label: "label here"
        })
      end)

      # We should get a different error (Runtime) if we
      # use the wrong type
      assert_raise(RuntimeError, fn ->
        Settings.add_server_setting_type(%{
          key: "#{__MODULE__} create errors",
          label: "label here",
          section: "test",
          type: "not a type"
        })
      end)

      # Do it correctly so we can test for duplicate key error
      {:ok, _} =
        Settings.add_server_setting_type(%{
          key: "#{__MODULE__} create errors",
          label: "label here",
          section: "test",
          type: "string"
        })

      assert_raise(RuntimeError, fn ->
        Settings.add_server_setting_type(%{
          key: "#{__MODULE__} create errors",
          label: "label here",
          section: "test",
          type: "string"
        })
      end)
    end

    test "create - correctly" do
      key = "#{__MODULE__} create"

      assert Settings.get_server_setting_type(key) == nil

      {result, type} =
        Settings.add_server_setting_type(%{
          key: key,
          label: "label here",
          section: "test",
          type: "string"
        })

      assert result == :ok
      assert type.key == key

      assert Settings.get_server_setting_type(key) == type
    end

    test "list types" do
      result = Settings.list_server_setting_types(["login.user_rate_limit"])
      assert Enum.count(result) == 1

      result = Settings.list_server_setting_types(["not a type"])
      assert Enum.empty?(result)
    end
  end
end
