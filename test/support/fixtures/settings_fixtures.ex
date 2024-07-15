defmodule Teiserver.Fixtures.SettingsFixtures do
  @moduledoc false
  alias Teiserver.Settings
  alias Teiserver.Settings.{ServerSettingType, ServerSetting, UserSetting}
  import Teiserver.Fixtures.AccountFixtures, only: [user_fixture: 0]

  @spec server_setting_type_fixture() :: ServerSettingType.t()
  @spec server_setting_type_fixture(map) :: ServerSettingType.t()
  def server_setting_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    {:ok, type} =
      Settings.add_server_setting_type(%{
        key: data["key"] || "key_#{r}",
        label: data["label"] || "label_#{r}",
        section: data["section"] || "section_#{r}",
        type: data["type"] || "string",
        permissions: data["permissions"] || nil,
        choices: data["choices"] || nil,
        default: data["default"] || nil,
        description: data["description"] || nil,
        validator: data["validator"] || nil
      })

    type
  end

  @spec server_setting_fixture() :: ServerSetting.t()
  @spec server_setting_fixture(map) :: ServerSetting.t()
  def server_setting_fixture(data \\ %{}) do
    type = data["type"] || server_setting_type_fixture()

    r = :rand.uniform(999_999_999)

    value =
      case type.type do
        "string" -> data["value"] || "#{r}"
        "integer" -> to_string(data["value"]) || "#{r}"
        "boolean" -> data["value"] || if Integer.mod(r, 2) == 1, do: "t", else: "f"
      end

    ServerSetting.changeset(
      %ServerSetting{},
      %{
        key: type.key,
        value: value
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec user_setting_type_fixture() :: UserSettingType.t()
  @spec user_setting_type_fixture(map) :: UserSettingType.t()
  def user_setting_type_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    {:ok, type} =
      Settings.add_user_setting_type(%{
        key: data["key"] || "key_#{r}",
        label: data["label"] || "label_#{r}",
        section: data["section"] || "section_#{r}",
        type: data["type"] || "string",
        permissions: data["permissions"] || nil,
        choices: data["choices"] || nil,
        default: data["default"] || nil,
        description: data["description"] || nil
      })

    type
  end

  @spec user_setting_fixture() :: UserSetting.t()
  @spec user_setting_fixture(map) :: UserSetting.t()
  def user_setting_fixture(data \\ %{}) do
    type = data["type"] || user_setting_type_fixture()

    r = :rand.uniform(999_999_999)

    value =
      case type.type do
        "string" -> data["value"] || "#{r}"
        "integer" -> to_string(data["value"]) || "#{r}"
        "boolean" -> data["value"] || if Integer.mod(r, 2) == 1, do: "t", else: "f"
      end

    UserSetting.changeset(
      %UserSetting{},
      %{
        user_id: data["user_id"] || user_fixture().id,
        key: type.key,
        value: value
      }
    )
    |> Teiserver.Repo.insert!()
  end
end
