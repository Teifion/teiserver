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
        colour: data["colour"] || "colour",
        icon: data["icon"] || "icon"
      },
      :full
    )
    |> Teiserver.repo.insert!
  end
end
