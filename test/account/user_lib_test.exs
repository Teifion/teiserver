defmodule Teiserver.UserLibTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Account
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

    test "user_query/0 returns a query" do
      q = Account.user_query([])
      assert %Ecto.Query{} = q
    end

    test "list_users/0 returns users" do
      # No users yet
      assert Account.list_users([]) == []

      # Add a user
      AccountFixtures.user_fixture()
      assert Account.list_users([]) != []
    end

    test "get_user!/1 and get_user/1 returns the user with given id" do
      user = AccountFixtures.user_fixture()
      assert Account.get_user!(user.id) == user
      assert Account.get_user(user.id) == user
    end

    test "get_user_by_X functions" do
      user1 = AccountFixtures.user_fixture()
      user2 = AccountFixtures.user_fixture()

      # Name
      assert Account.get_user_by_name(user1.name) == user1
      assert Account.get_user_by_name(user2.name) == user2

      # Email
      assert Account.get_user_by_email(user1.email) == user1
      assert Account.get_user_by_email(user2.email) == user2

      # ID
      assert Account.get_user_by_id(user1.id) == user1
      assert Account.get_user_by_id(user2.id) == user2
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Account.create_user(@valid_attrs)
      assert user.permissions == []
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = AccountFixtures.user_fixture()
      assert {:ok, %User{} = user} = Account.update_user(user, @update_attrs)
      assert user.name == "some updated name"
      assert user.permissions == []
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = AccountFixtures.user_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_user(user, @invalid_attrs)
      assert user == Account.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = AccountFixtures.user_fixture()
      assert {:ok, %User{}} = Account.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Account.get_user!(user.id) end
      assert Account.get_user(user.id) == nil
    end

    test "change_user/1 returns a user changeset" do
      user = AccountFixtures.user_fixture()
      assert %Ecto.Changeset{} = Account.change_user(user)
    end

    test "valid_password?/2" do
      user = AccountFixtures.user_fixture(%{"password" => "password"})
      assert Account.valid_password?(user, "password")
      refute Account.valid_password?(user, "bad_password")
    end

    test "allow?/2" do
      # User must have all of the required permissions
      user = AccountFixtures.user_fixture(%{"groups" => ["perm1", "perm2"]})
      assert Account.allow?(user, "perm1")
      assert Account.allow?(user.id, "perm1")
      assert Account.allow?(user.id, ["perm1"])
      assert Account.allow?(user.id, "perm2")
      assert Account.allow?(user.id, ["perm1", "perm2"])

      # Missing any of the permissions results in a false
      refute Account.allow?(user.id, ["perm3"])
      refute Account.allow?(user.id, ["perm1", "perm3"])

      # No user or bad user_id results in a false
      refute Account.allow?(-1, ["perm1"])
      refute Account.allow?(nil, ["perm1"])

      # No required permissions, it's accepted
      assert Account.allow?(user.id, [])
    end

    test "refute?/2" do
      # Possessing any of the restrictions results in a true value
      user = AccountFixtures.user_fixture(%{"restrictions" => ["restrict1", "restrict2"]})
      assert Account.restricted?(user, "restrict1")
      assert Account.restricted?(user.id, "restrict1")
      assert Account.restricted?(user.id, ["restrict1"])
      assert Account.restricted?(user.id, "restrict2")
      assert Account.restricted?(user.id, ["restrict1", "restrict2"])

      # A user must be absent all of the restrictions to get a false
      refute Account.restricted?(user.id, ["restrict3"])
      refute Account.restricted?(user.id, [])

      # No user or bad user_id results in a true (defaults to restricted)
      assert Account.restricted?(-1, ["restrict1"])
      assert Account.restricted?(nil, ["restrict1"])
    end
  end

  describe "pure functions" do
    test "topic" do
      user = AccountFixtures.user_fixture()
      expected = "Teiserver.Account.User:#{user.id}"
      assert Account.user_topic(user) == expected
      assert Account.user_topic(user.id) == expected
    end
  end

  describe "user related functions" do
    test "generate password" do
      p = Account.generate_password()
      assert String.length(p) > 30
    end
  end
end
