defmodule Teiserver.AccountTest do
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

    test "list_users/0 returns users" do
      # No users yet
      assert Account.list_users() == []
      assert Account.list_users([]) == []

      # Add a user
      AccountFixtures.user_fixture()
      assert Account.list_users() != []

      # Add a user
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

    test "verify_password/2" do
      user = AccountFixtures.user_fixture(%{"password" => "password"})
      assert Account.verify_user_password(user, "password")
      refute Account.verify_user_password(user, "bad_password")
    end
  end
end
