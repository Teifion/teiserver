defmodule Teiserver.Logging.AuditLogQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Logging.AuditLog
  require Logger

  @spec audit_log_query(Teiserver.query_args()) :: Ecto.Query.t()
  def audit_log_query(args) do
    query = from(audit_logs in AuditLog)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_where(args[:search])
    |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id_list) when is_list(id_list) do
    from(audit_logs in query,
      where: audit_logs.id in ^id_list
    )
  end

  def _where(query, :id, id) do
    from(audit_logs in query,
      where: audit_logs.id == ^id
    )
  end

  def _where(query, :user_id, user_id_list) when is_list(user_id_list) do
    from(audit_logs in query,
      where: audit_logs.user_id in ^user_id_list
    )
  end

  def _where(query, :user_id, user_id) do
    from(audit_logs in query,
      where: audit_logs.user_id == ^user_id
    )
  end

  def _where(query, :action, action_list) when is_list(action_list) do
    from(audit_logs in query,
      where: audit_logs.action in ^action_list
    )
  end

  def _where(query, :action, action) do
    from(audit_logs in query,
      where: audit_logs.action == ^action
    )
  end

  def _where(query, :detail_equal, {field, value}) do
    from(audit_logs in query,
      where: fragment("? ->> ? = ?", audit_logs.details, ^field, ^value)
    )
  end

  def _where(query, :detail_greater_than, {field, value}) do
    from(audit_logs in query,
      where: fragment("? ->> ? > ?", audit_logs.details, ^field, ^value)
    )
  end

  def _where(query, :detail_less_than, {field, value}) do
    from(audit_logs in query,
      where: fragment("? ->> ? < ?", audit_logs.details, ^field, ^value)
    )
  end

  def _where(query, :detail_not, {field, value}) do
    from(audit_logs in query,
      where: fragment("? ->> ? != ?", audit_logs.details, ^field, ^value)
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(audit_logs in query,
      where: audit_logs.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(audit_logs in query,
      where: audit_logs.inserted_at < ^timestamp
    )
  end

  def _where(query, :updated_after, timestamp) do
    from(audit_logs in query,
      where: audit_logs.updated_at >= ^timestamp
    )
  end

  def _where(query, :updated_before, timestamp) do
    from(audit_logs in query,
      where: audit_logs.updated_at < ^timestamp
    )
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) when is_list(params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Newest first") do
    from(audit_logs in query,
      order_by: [desc: audit_logs.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(audit_logs in query,
      order_by: [asc: audit_logs.inserted_at]
    )
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :user) do
    from(audit_log in query,
      left_join: users in assoc(audit_log, :user),
      preload: [user: users]
    )
  end
end
