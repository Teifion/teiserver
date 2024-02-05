defmodule Teiserver.MatchLibTest do
  @moduledoc false
  alias Teiserver.Game.Match
  alias Teiserver.Game
  use Teiserver.Case, async: true

  alias Teiserver.Game
  alias Teiserver.{GameFixtures, AccountFixtures}

  defp valid_attrs do
    %{
      name: "some name",
      public?: true,
      rated?: true,
      host_id: AccountFixtures.user_fixture().id
    }
  end

  defp update_attrs do
    %{
      name: "some updated name",
      public?: false,
      rated?: false,
      host_id: AccountFixtures.user_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      name: nil,
      public?: nil,
      rated?: nil,
      host_id: nil
    }
  end

  describe "match" do
    alias Teiserver.Game.Match

    test "match_query/0 returns a query" do
      q = Game.match_query([])
      assert %Ecto.Query{} = q
    end

    test "list_match/0 returns match" do
      # No match yet
      assert Game.list_matches([]) == []

      # Add a match
      GameFixtures.completed_match_fixture()
      assert Game.list_matches([]) != []
    end


    test "get_match!/1 and get_match/1 returns the match with given id" do
      match = GameFixtures.completed_match_fixture()
      assert Game.get_match!(match.id) == match
      assert Game.get_match(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      assert {:ok, %Match{} = match} =
               Game.create_match(valid_attrs())

      assert match.name == "some name"
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_match(invalid_attrs())
    end

    test "update_match/2 with valid data updates the match" do
      match = GameFixtures.completed_match_fixture()

      assert {:ok, %Match{} = match} =
               Game.update_match(match, update_attrs())

      assert match.name == "some updated name"
      assert match.name == "some updated name"
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = GameFixtures.completed_match_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Game.update_match(match, invalid_attrs())

      assert match == Game.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = GameFixtures.completed_match_fixture()
      assert {:ok, %Match{}} = Game.delete_match(match)

      assert_raise Ecto.NoResultsError, fn ->
        Game.get_match!(match.id)
      end

      assert Game.get_match(match.id) == nil
    end

    test "change_match/1 returns a match changeset" do
      match = GameFixtures.completed_match_fixture()
      assert %Ecto.Changeset{} = Game.change_match(match)
    end
  end
end
