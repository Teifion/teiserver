defmodule Teiserver.Fixtures.LoggingFixtures do
  @moduledoc false
  import Teiserver.Fixtures.AccountFixtures, only: [user_fixture: 0]
  alias Teiserver.Logging.{AuditLog}

  @spec audit_log_fixture() :: AuditLog.t()
  @spec audit_log_fixture(map) :: AuditLog.t()
  def audit_log_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    AuditLog.changeset(
      %AuditLog{},
      %{
        action: data[:action] || "action_#{r}",
        details: data[:details] || %{},
        ip: data[:ip] || "ip_#{r}",
        user_id: data[:user_id] || user_fixture().id
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec anonymous_audit_log_fixture() :: AuditLog.t()
  @spec anonymous_audit_log_fixture(map) :: AuditLog.t()
  def anonymous_audit_log_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    AuditLog.changeset(
      %AuditLog{},
      %{
        action: data[:action] || "action_#{r}",
        details: data[:details] || %{},
        ip: data[:ip] || "ip_#{r}",
        user_id: nil
      }
    )
    |> Teiserver.Repo.insert!()
  end
end
