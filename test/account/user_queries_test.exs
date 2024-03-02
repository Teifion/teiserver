defmodule Teiserver.UserQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Account.UserQueries

  describe "queries" do
    @empty_query UserQueries.user_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        UserQueries.user_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        UserQueries.user_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        UserQueries.user_query(
          where: [
            id: [Ecto.UUID.generate(), Ecto.UUID.generate()],
            id: Ecto.UUID.generate(),
            name: "name",
            name_lower: "name_lower",
            email: "email",
            email_lower: "email_lower",
            name_or_email: "name_or_email",
            name_like: "name_like",
            basic_search: "basic_search",
            inserted_after: Timex.now(),
            inserted_before: Timex.now(),
            has_group: "has_group",
            not_has_group: "not_has_group",
            has_permission: "has_permission",
            not_has_permission: "not_has_permission",
            has_restriction: "has_restriction",
            not_has_restriction: "not_has_restriction",
            smurf_of: Ecto.UUID.generate(),
            smurf_of: "Smurf",
            smurf_of: "Non-smurf",
            behaviour_score_gt: 123,
            behaviour_score_lt: 123,
            last_played_after: Timex.now(),
            last_played_before: Timex.now(),
            last_login_after: Timex.now(),
            last_login_before: Timex.now()
          ],
          order_by: [
            "Name (A-Z)",
            "Name (Z-A)",
            "Newest first",
            "Oldest first",
            "Last logged in",
            "Last played",
            "Last logged out"
          ],
          preload: [
            :extra_data
          ],
          limit: nil,
          select: [:id]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
