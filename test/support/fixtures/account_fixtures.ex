defmodule Teiserver.AccountFixtures do
  @moduledoc false
  alias Teiserver.Account.User

  def user_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    User.changeset(
      %User{},
      %{
        name: data["name"] || "name_#{r}",
        email: data["email"] || "email_#{r}",
        password: data["password"] || "password_#{r}",
      },
      :full
    )
    |> Teiserver.repo.insert!
  end
end
