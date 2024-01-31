defmodule Helpers.SchemaHelperTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Helpers.SchemaHelper

  describe "helpers" do
    test "trim strings" do
      params = %{"a" => "abc", "b" => " abc ", "c" => "abc ", "d" => " abc"}
      names = [:a, :b, :c, :d]

      result = SchemaHelper.trim_strings(params, names)
      assert result == %{"a" => "abc", "b" => "abc", "c" => "abc", "d" => "abc"}
    end

    test "min_and_max" do
      params = %{"v1" => 123, "v2" => 5, "v3" => 123, "v4" => 1000}

      result1 = SchemaHelper.min_and_max(params, [:v1, :v2])
      assert result1 == %{"v1" => 5, "v2" => 123, "v3" => 123, "v4" => 1000}

      result2 = SchemaHelper.min_and_max(params, [:v3, :v4])
      assert result2 == %{"v1" => 123, "v2" => 5, "v3" => 123, "v4" => 1000}
    end

    test "uniq_lists" do
      params = %{
        "l1" => [1, 2, 3],
        "l2" => [1, 1, 1],
        "l3" => [1, 1, 11, 2],
        "l4" => [3, 3, 3],
        "l6" => nil
      }

      names = [:l1, :l2, :l3, :l5, :l6]

      result = SchemaHelper.uniq_lists(params, names)

      assert result == %{
               "l1" => [1, 2, 3],
               "l2" => [1],
               "l3" => [1, 11, 2],
               "l4" => [3, 3, 3],
               "l6" => nil
             }
    end
  end
end
