defmodule Teiserver.UserChoiceTypeQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Game.UserChoiceTypeQueries

  describe "queries" do
    @empty_query UserChoiceTypeQueries.user_choice_type_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        UserChoiceTypeQueries.user_choice_type_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        UserChoiceTypeQueries.user_choice_type_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        UserChoiceTypeQueries.user_choice_type_query(
          where: [
            id: [1, 2],
            id: 1,
            name: ["abc", "def"],
            name: "Some name"
          ],
          order_by: [
            "Name (A-Z)",
            "Name (Z-A)"
          ],
          preload: []
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
