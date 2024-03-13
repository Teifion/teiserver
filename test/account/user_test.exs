defmodule Account.UserTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.AccountFixtures
  alias Teiserver.Account.User

  describe "User" do
    test "changesets" do
      user = AccountFixtures.user_fixture()
      c = User.changeset(user)
      assert %Ecto.Changeset{} = c
    end

    test "full changeset" do
      user = AccountFixtures.user_fixture()

      no_change = User.changeset(user, %{}, :full)
      assert no_change.changes == %{}

      basic_change = User.changeset(user, %{email: user.email <> "abc"}, :full)
      assert basic_change.valid?

      bad_email = User.changeset(user, %{email: ""}, :full)
      refute bad_email.valid?

      with_password =
        User.changeset(user, %{"email" => user.email <> "abc", "password" => "123456"}, :full)

      assert with_password.valid?

      empty_password =
        User.changeset(user, %{"email" => user.email <> "abc", "password" => ""}, :full)

      assert empty_password.valid?

      permissions = User.changeset(user, ~w(a b c), :permissions)
      assert permissions.valid?

      profile = User.changeset(user, %{email: "123123"}, :profile)
      assert profile.valid?

      # User form
      user_form_no_pass = User.changeset(user, %{"email" => user.email <> "abc"}, :user_form)
      refute user_form_no_pass.valid?

      user_form_bad_pass =
        User.changeset(
          user,
          %{"email" => user.email <> "abc", "password" => "badpass"},
          :user_form
        )

      refute user_form_bad_pass.valid?

      user_form_pass =
        User.changeset(
          user,
          %{"email" => user.email <> "abc", "password" => "password"},
          :user_form
        )

      assert user_form_pass.valid?

      # Change password
      no_existing = User.changeset(user, %{"password" => "password1"}, :change_password)
      refute no_existing.valid?

      bad_existing =
        User.changeset(user, %{"existing" => "bad", "password" => "password1"}, :change_password)

      refute bad_existing.valid?

      good_existing =
        User.changeset(
          user,
          %{"existing" => "password", "password" => "password1"},
          :change_password
        )

      assert good_existing.valid?

      forgot_password = User.changeset(user, %{"password" => "password1"}, :forgot_password)
      assert forgot_password.valid?
    end
  end
end
