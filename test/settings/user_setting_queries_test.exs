defmodule Teiserver.UserSettingQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Settings.UserSettingQueries

  describe "queries" do
    @empty_query UserSettingQueries.user_setting_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        UserSettingQueries.user_setting_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        UserSettingQueries.user_setting_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        UserSettingQueries.user_setting_query(
          where: [
            user_id: [Teiserver.uuid(), Teiserver.uuid()],
            user_id: Teiserver.uuid(),
            key: ["key1", "key2"],
            key: "key1",
            value: ["value1", "value2"],
            value: "value1",
            inserted_after: DateTime.utc_now(),
            inserted_before: DateTime.utc_now(),
            updated_after: DateTime.utc_now(),
            updated_before: DateTime.utc_now()
          ],
          order_by: [
            "Newest first",
            "Oldest first"
          ],
          limit: nil,
          select: [:key]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
