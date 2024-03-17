defmodule Helpers.MapHelperTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Helpers.MapHelper

  describe "map_diff" do
    test "Changing keys" do
      # Atom keys
      m1 = %{a: 123, b: 456}
      m2 = %{a: 123, b: 789}

      result = MapHelper.map_diffs(m1, m2)
      assert result == %{b: 789}

      # String keys
      m1 = %{"a" => 123, "b" => 456}
      m2 = %{"a" => 123, "b" => 789}

      result = MapHelper.map_diffs(m1, m2)
      assert result == %{"b" => 789}
    end

    test "Adding keys" do
      # Atom keys
      m1 = %{a: 123, b: 456}
      m2 = %{a: 123, b: 456, c: 789}

      result = MapHelper.map_diffs(m1, m2)
      assert result == %{c: 789}

      # String keys
      m1 = %{"a" => 123, "b" => 456}
      m2 = %{"a" => 123, "b" => 456, "c" => 789}

      result = MapHelper.map_diffs(m1, m2)
      assert result == %{"c" => 789}
    end

    test "lobby structs" do
      alias Teiserver.Game.Lobby
      id = Teiserver.uuid()

      l1 = Lobby.new(id, "l1")
      l2 = struct(l1, %{match_ongoing?: true, game_name: "New name"})

      result = MapHelper.map_diffs(l1, l2)
      assert result == %{match_ongoing?: true, game_name: "New name"}
    end

    test "no changes" do
      # Atom keys
      m1 = %{a: 123, b: 456}
      m2 = %{a: 123, b: 456}

      result = MapHelper.map_diffs(m1, m2)
      assert result == %{}

      # String keys
      m1 = %{"a" => 123, "b" => 456}
      m2 = %{"a" => 123, "b" => 456}

      result = MapHelper.map_diffs(m1, m2)
      assert result == %{}
    end
  end
end
