defmodule Teiserver.AuditLogLibTest do
  @moduledoc false
  alias Teiserver.Logging.AuditLog
  alias Teiserver.Logging
  use Teiserver.Case, async: true

  alias Teiserver.Fixtures.{LoggingFixtures, AccountFixtures}

  defp valid_attrs do
    %{
      action: "some action",
      ip: "127.0.0.1",
      details: %{key: 1},
      user_id: AccountFixtures.user_fixture().id
    }
  end

  defp update_attrs do
    %{
      action: "some updated action",
      ip: "127.0.0.127",
      details: %{key: "updated"},
      user_id: AccountFixtures.user_fixture().id
    }
  end

  defp invalid_attrs do
    %{
      action: nil,
      ip: nil,
      details: nil,
      user_id: nil
    }
  end

  describe "audit_log" do
    alias Teiserver.Logging.AuditLog

    test "audit_log_query/0 returns a query" do
      q = Logging.audit_log_query([])
      assert %Ecto.Query{} = q
    end

    test "list_audit_log/0 returns audit_log" do
      # No audit_log yet
      assert Logging.list_audit_logs([]) == []

      # Add a audit_log
      LoggingFixtures.audit_log_fixture()
      assert Logging.list_audit_logs([]) != []
    end

    test "get_audit_log!/1 and get_audit_log/1 returns the audit_log with given id" do
      audit_log = LoggingFixtures.audit_log_fixture()
      assert Logging.get_audit_log!(audit_log.id) == audit_log
      assert Logging.get_audit_log(audit_log.id) == audit_log
    end

    test "create_audit_log/1 with valid data creates a audit_log" do
      assert {:ok, %AuditLog{} = audit_log} =
               Logging.create_audit_log(valid_attrs())

      assert audit_log.action == "some action"
    end

    test "create_audit_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_audit_log(invalid_attrs())
    end

    test "create_audit_log/4 with valid data creates a audit_log" do
      user_id = AccountFixtures.user_fixture().id

      assert {:ok, %AuditLog{} = audit_log} =
               Logging.create_audit_log(user_id, "ip", "some action", %{})

      assert audit_log.action == "some action"
    end

    test "create_audit_log/4 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_audit_log(nil, nil, nil, nil)
    end

    test "create_anonymous_audit_log/3 with valid data creates a audit_log" do
      assert {:ok, %AuditLog{} = audit_log} =
               Logging.create_anonymous_audit_log("ip", "some action", %{})

      assert audit_log.action == "some action"
    end

    test "create_anonymous_audit_log/3 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_anonymous_audit_log(nil, nil, nil)
    end

    test "update_audit_log/2 with valid data updates the audit_log" do
      audit_log = LoggingFixtures.audit_log_fixture()

      assert {:ok, %AuditLog{} = audit_log} =
               Logging.update_audit_log(audit_log, update_attrs())

      assert audit_log.action == "some updated action"
    end

    test "update_audit_log/2 with invalid data returns error changeset" do
      audit_log = LoggingFixtures.audit_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_audit_log(audit_log, invalid_attrs())

      assert audit_log == Logging.get_audit_log!(audit_log.id)
    end

    test "delete_audit_log/1 deletes the audit_log" do
      audit_log = LoggingFixtures.audit_log_fixture()
      assert {:ok, %AuditLog{}} = Logging.delete_audit_log(audit_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_audit_log!(audit_log.id)
      end

      assert Logging.get_audit_log(audit_log.id) == nil
    end

    test "change_audit_log/1 returns a audit_log changeset" do
      audit_log = LoggingFixtures.audit_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_audit_log(audit_log)
    end
  end
end
