defmodule Teiserver.MatchSettingQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Game.MatchSettingQueries

  describe "queries" do
    @empty_query MatchSettingQueries.match_setting_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        MatchSettingQueries.match_setting_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        MatchSettingQueries.match_setting_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        MatchSettingQueries.match_setting_query(
          where: [
            type_id: [1, 2],
            type_id: 1,
            match_id: [1, 2],
            match_id: 1,
            value: ["abc", "def"],
            value: "abc"
          ],
          order_by: [
            "Value (A-Z)",
            "Value (Z-A)",
          ],
          preload: [
            :match,
            :type
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
