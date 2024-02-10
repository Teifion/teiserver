defmodule Teiserver.MatchMembershipQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Game.MatchMembershipQueries

  describe "queries" do
    @empty_query MatchMembershipQueries.match_membership_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        MatchMembershipQueries.match_membership_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        MatchMembershipQueries.match_membership_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        MatchMembershipQueries.match_membership_query(
          where: [
            user_id: [1, 2],
            user_id: 1,
            match_id: [1, 2],
            match_id: 1,
            win?: true,
            party_id: ["abc", "def"],
            party_id: "abc",
            team_number: [1, 2],
            team_number: 1
          ],
          order_by: [
            "First to leave",
            "Last to leave"
          ],
          preload: [
            :match,
            :user
          ]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
