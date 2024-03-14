defmodule Teiserver.MatchMessageQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Communication.MatchMessageQueries

  describe "queries" do
    @empty_query MatchMessageQueries.match_message_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        MatchMessageQueries.match_message_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        MatchMessageQueries.match_message_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        MatchMessageQueries.match_message_query(
          where: [
            id: [1, 2],
            id: 1,
            sender_id: [Teiserver.uuid(), Teiserver.uuid()],
            sender_id: Teiserver.uuid(),
            match_id: [Teiserver.uuid(), Teiserver.uuid()],
            match_id: Teiserver.uuid(),
            inserted_after: Timex.now(),
            inserted_before: Timex.now()
          ],
          order_by: [
            "Newest first",
            "Oldest first"
          ],
          preload: [
            :sender,
            :match
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
