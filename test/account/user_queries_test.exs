defmodule Teiserver.UserQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Account.UserQueries

  describe "queries" do
    @empty_query UserQueries.user_query()

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values = UserQueries.user_query(
        where: [
          key1: "",
          key2: nil
        ]
      )

      assert null_values == @empty_query
      Repo.all(null_values)

      # # We expect all these to be present
      # we expect the query to run though it won't produce meaningful results
      all_values = UserQueries.user_query(
        where: [
          id: [1, 2],
          id: 1,
          name: "name",
          name_lower: "name_lower",
          email: "email",
          email_lower: "email_lower",
          name_or_email: "name_or_email",
          name_like: "name_like",
          basic_search: "basic_search",
          inserted_after: Timex.now(),
          inserted_before: Timex.now(),
          has_role: "has_role",
          not_has_role: "not_has_role",
          has_permission: "has_permission",
          not_has_permission: "not_has_permission",
          has_restriction: "has_restriction",
          not_has_restriction: "not_has_restriction",
          smurf_of: 123,
          smurf_of: "Smurf",
          smurf_of: "Non-smurf",
          behaviour_score_gt: 123,
          behaviour_score_lt: 123,
          last_played_after: Timex.now(),
          last_played_before: Timex.now(),
          last_login_after: Timex.now(),
          last_login_before: Timex.now()
        ],
        order_by: ["Name (A-Z)", "Name (Z-A)", "Newest first", "Oldest first", "Last logged in", "Last played", "Last logged out"],
        preload: [
          :extra_data
        ]
      )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
