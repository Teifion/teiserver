defmodule Teiserver.Logging do
  @moduledoc """
  The contextual module for:
  - `Teiserver.Logging.AuditLog`
  """

  # AuditLogs
  alias Teiserver.Logging.{AuditLog, AuditLogLib, AuditLogQueries}

  @doc false
  @spec audit_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate audit_log_query(args), to: AuditLogQueries

  @doc section: :audit_log
  @spec list_audit_logs(Teiserver.query_args()) :: [AuditLog.t()]
  defdelegate list_audit_logs(args), to: AuditLogLib

  @doc section: :audit_log
  @spec get_audit_log!(AuditLog.id()) :: AuditLog.t()
  @spec get_audit_log!(AuditLog.id(), Teiserver.query_args()) :: AuditLog.t()
  defdelegate get_audit_log!(audit_log_id, query_args \\ []), to: AuditLogLib

  @doc section: :audit_log
  @spec get_audit_log(AuditLog.id()) :: AuditLog.t() | nil
  @spec get_audit_log(AuditLog.id(), Teiserver.query_args()) :: AuditLog.t() | nil
  defdelegate get_audit_log(audit_log_id, query_args \\ []), to: AuditLogLib

  @doc section: :audit_log
  @spec create_audit_log(map) :: {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_audit_log(attrs), to: AuditLogLib

  @doc section: :audit_log
  @spec create_audit_log(Teiserver.user_id(), String.t(), String.t(), map()) ::
          {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_audit_log(user_id, ip, action, details), to: AuditLogLib

  @doc section: :audit_log
  @spec create_anonymous_audit_log(String.t(), String.t(), map()) ::
          {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_anonymous_audit_log(ip, action, details), to: AuditLogLib

  @doc section: :audit_log
  @spec update_audit_log(AuditLog, map) :: {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_audit_log(audit_log, attrs), to: AuditLogLib

  @doc section: :audit_log
  @spec delete_audit_log(AuditLog.t()) :: {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_audit_log(audit_log), to: AuditLogLib

  @doc section: :audit_log
  @spec change_audit_log(AuditLog.t()) :: Ecto.Changeset.t()
  @spec change_audit_log(AuditLog.t(), map) :: Ecto.Changeset.t()
  defdelegate change_audit_log(audit_log, attrs \\ %{}), to: AuditLogLib
end
