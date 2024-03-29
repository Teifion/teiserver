defmodule Teiserver.DirectMessageQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Communication.DirectMessageQueries

  describe "queries" do
    @empty_query DirectMessageQueries.direct_message_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        DirectMessageQueries.direct_message_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        DirectMessageQueries.direct_message_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        DirectMessageQueries.direct_message_query(
          where: [
            id: [1, 2],
            id: 1,
            from_id: [1, 2],
            from_id: 1,
            to_id: [1, 2],
            to_id: 1,
            to_or_from_id: [1, 2],
            to_or_from_id: 1,
            inserted_after: Timex.now(),
            inserted_before: Timex.now()
          ],
          order_by: [
            "Newest first",
            "Oldest first"
          ],
          preload: [
            :from,
            :to
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
