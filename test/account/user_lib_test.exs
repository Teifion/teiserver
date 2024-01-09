defmodule Teiserver.UserLibTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Account.UserLib
  alias Teiserver.AccountFixtures

  describe "users" do
    alias Teiserver.Account.User

    @valid_attrs %{
      name: "some name",
      permissions: [],
      email: "AnEmailAddress@email.com",
      password: "some password"
    }
    @update_attrs %{
      permissions: [],
      name: "some updated name",
      email: "some updated email",
      password: "some updated password"
    }
    @invalid_attrs %{
      name: nil,
      permissions: nil,
      email: nil,
      password: nil
    }

    test "list_users/0 returns users" do
      # No users yet
      assert UserLib.list_users() == []
      assert UserLib.list_users([]) == []

      # Add a user
      AccountFixtures.user_fixture()
      assert UserLib.list_users() != []

      # Add a user
      assert UserLib.list_users([]) != []
    end

    test "get_user!/1 and get_user/1 returns the user with given id" do
      user = AccountFixtures.user_fixture()
      assert UserLib.get_user!(user.id) == user
      assert UserLib.get_user(user.id) == user
    end

    test "get_user_by_X functions" do
      user1 = AccountFixtures.user_fixture()
      user2 = AccountFixtures.user_fixture()

      # Name
      assert UserLib.get_user_by_name(user1.name) == user1
      assert UserLib.get_user_by_name(user2.name) == user2

      # Email
      assert UserLib.get_user_by_email(user1.email) == user1
      assert UserLib.get_user_by_email(user2.email) == user2

      # ID
      assert UserLib.get_user_by_id(user1.id) == user1
      assert UserLib.get_user_by_id(user2.id) == user2
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = UserLib.create_user(@valid_attrs)
      assert user.permissions == []
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserLib.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = AccountFixtures.user_fixture()
      assert {:ok, %User{} = user} = UserLib.update_user(user, @update_attrs)
      assert user.name == "some updated name"
      assert user.permissions == []
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = AccountFixtures.user_fixture()
      assert {:error, %Ecto.Changeset{}} = UserLib.update_user(user, @invalid_attrs)
      assert user == UserLib.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = AccountFixtures.user_fixture()
      assert {:ok, %User{}} = UserLib.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserLib.get_user!(user.id) end
      assert UserLib.get_user(user.id) == nil
    end

    test "change_user/1 returns a user changeset" do
      user = AccountFixtures.user_fixture()
      assert %Ecto.Changeset{} = UserLib.change_user(user)
    end

    test "verify_password/2" do
      user = AccountFixtures.user_fixture(%{"password" => "password"})
      assert UserLib.verify_user_password(user, "password")
      refute UserLib.verify_user_password(user, "bad_password")
    end

    test "allow?/2" do
      # User must have all of the required permissions
      user = AccountFixtures.user_fixture(%{"permissions" => ["perm1", "perm2"]})
      assert UserLib.allow?(user, "perm1")
      assert UserLib.allow?(user.id, "perm1")
      assert UserLib.allow?(user.id, ["perm1"])
      assert UserLib.allow?(user.id, "perm2")
      assert UserLib.allow?(user.id, ["perm1", "perm2"])

      # Missing any of the permissions results in a false
      refute UserLib.allow?(user.id, ["perm3"])
      refute UserLib.allow?(user.id, ["perm1", "perm3"])

      # No user or bad user_id results in a false
      refute UserLib.allow?(-1, ["perm1"])
      refute UserLib.allow?(nil, ["perm1"])

      # No required permissions, it's accepted
      assert UserLib.allow?(user.id, [])
    end

    test "refute?/2" do
      # Possessing any of the restrictions results in a true value
      user = AccountFixtures.user_fixture(%{"restrictions" => ["restrict1", "restrict2"]})
      assert UserLib.restricted?(user, "restrict1")
      assert UserLib.restricted?(user.id, "restrict1")
      assert UserLib.restricted?(user.id, ["restrict1"])
      assert UserLib.restricted?(user.id, "restrict2")
      assert UserLib.restricted?(user.id, ["restrict1", "restrict2"])

      # A user must be absent all of the restrictions to get a false
      refute UserLib.restricted?(user.id, ["restrict3"])
      refute UserLib.restricted?(user.id, [])

      # No user or bad user_id results in a true (defaults to restricted)
      assert UserLib.restricted?(-1, ["restrict1"])
      assert UserLib.restricted?(nil, ["restrict1"])
    end
  end
end
