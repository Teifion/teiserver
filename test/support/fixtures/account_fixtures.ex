defmodule Teiserver.AccountFixtures do
  @moduledoc false
  alias Teiserver.Account.{User, ExtraUserData}

  @spec user_fixture() :: User.t()
  @spec user_fixture(map) :: User.t()
  def user_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    User.changeset(
      %User{},
      %{
        name: data["name"] || "user_name_#{r}",
        email: data["email"] || "user_email_#{r}",
        password: data["password"] || "password",
        roles: data["roles"] || [],
        permissions: data["permissions"] || [],
        restrictions: data["restrictions"] || []
      },
      :full
    )
    |> Teiserver.Repo.insert!()
  end

  @spec extra_user_data_fixture(map) :: ExtraUserData.t()
  def extra_user_data_fixture(data \\ %{}) do
    ExtraUserData.changeset(
      %ExtraUserData{},
      %{
        user_id: data[:user_id] || user_fixture().id,
        data: data[:data] || %{}
      }
    )
    |> Teiserver.Repo.insert!()
  end
end
