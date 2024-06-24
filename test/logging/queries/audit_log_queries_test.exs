defmodule Teiserver.AuditLogQueriesTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.Logging.AuditLogQueries

  describe "queries" do
    @empty_query AuditLogQueries.audit_log_query([])

    test "clauses" do
      # Null values, shouldn't error but shouldn't generate a query
      null_values =
        AuditLogQueries.audit_log_query(
          where: [
            key1: "",
            key2: nil
          ]
        )

      assert null_values == @empty_query
      Repo.all(null_values)

      # If a key is not present in the query library it should error
      assert_raise(FunctionClauseError, fn ->
        AuditLogQueries.audit_log_query(where: [not_a_key: 1])
      end)

      # we expect the query to run though it won't produce meaningful results
      all_values =
        AuditLogQueries.audit_log_query(
          where: [
            id: [1, 2],
            id: 1,
            user_id: [
              "0ea89483-80da-4041-9e41-fcb152c24168",
              "7fa72464-e3b6-42e8-935e-608adc65608e"
            ],
            user_id: "57b86216-5a32-4e76-bad0-1012a825667b",
            action: ["action1", "action2"],
            action: "action",
            detail_equal: {"key", "value"},
            detail_greater_than: {"key", "value"},
            detail_less_than: {"key", "value"},
            detail_not: {"key", "value"},
            inserted_after: Timex.now(),
            inserted_before: Timex.now(),
            updated_after: Timex.now(),
            updated_before: Timex.now()
          ],
          order_by: [
            "Newest first",
            "Oldest first"
          ],
          preload: [:user]
        )

      assert all_values != @empty_query
      Repo.all(all_values)
    end
  end
end
