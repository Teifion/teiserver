defmodule Teiserver.Logging.AuditLogLib do
  @moduledoc """
  Library of AuditLog related functions
  """
  use TeiserverMacros, :library
  alias Teiserver.Logging.{AuditLog, AuditLogQueries}

  @doc """
  Returns the list of audit_logs.

  ## Examples

      iex> list_audit_logs()
      [%AuditLog{}, ...]

  """
  @spec list_audit_logs(Teiserver.query_args()) :: [AuditLog.t()]
  def list_audit_logs(query_args) do
    query_args
    |> AuditLogQueries.audit_log_query()
    |> Repo.all()
  end

  @doc """
  Gets a single audit_log.

  Raises `Ecto.NoResultsError` if the AuditLog does not exist.

  ## Examples

      iex> get_audit_log!(123)
      %AuditLog{}

      iex> get_audit_log!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_audit_log!(AuditLog.id()) :: AuditLog.t()
  @spec get_audit_log!(AuditLog.id(), Teiserver.query_args()) :: AuditLog.t()
  def get_audit_log!(audit_log_id, query_args \\ []) do
    (query_args ++ [id: audit_log_id])
    |> AuditLogQueries.audit_log_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single audit_log.

  Returns nil if the AuditLog does not exist.

  ## Examples

      iex> get_audit_log(123)
      %AuditLog{}

      iex> get_audit_log(456)
      nil

  """
  @spec get_audit_log(AuditLog.id()) :: AuditLog.t() | nil
  @spec get_audit_log(AuditLog.id(), Teiserver.query_args()) :: AuditLog.t() | nil
  def get_audit_log(audit_log_id, query_args \\ []) do
    (query_args ++ [id: audit_log_id])
    |> AuditLogQueries.audit_log_query()
    |> Repo.one()
  end

  @doc """
  Creates a audit_log.

  ## Examples

      iex> create_audit_log(%{field: value})
      {:ok, %AuditLog{}}

      iex> create_audit_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_audit_log("user_id", "127.0.0.1", "Action", %{key: "value"})
      {:ok, %AuditLog{}}

  """
  @spec create_audit_log(map) :: {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  def create_audit_log(attrs) do
    %AuditLog{}
    |> AuditLog.changeset(attrs)
    |> Repo.insert()
  end

  @spec create_audit_log(Teiserver.user_id(), String.t(), String.t(), map()) ::
          {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  def create_audit_log(user_id, ip, action, details) do
    %AuditLog{}
    |> AuditLog.changeset(%{
      user_id: user_id,
      ip: ip,
      action: action,
      details: details
    })
    |> Repo.insert()
    |> maybe_emit_event
  end

  @doc """
  See `create_audit_log/4`, this is the same but without a user.
  """
  @spec create_anonymous_audit_log(String.t(), String.t(), map()) ::
          {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  def create_anonymous_audit_log(ip, action, details) do
    %AuditLog{}
    |> AuditLog.changeset(%{
      ip: ip,
      action: action,
      details: details
    })
    |> Repo.insert()
    |> maybe_emit_event
  end

  defp maybe_emit_event({:ok, %AuditLog{} = audit_log}) do
    :telemetry.execute(
      [:teiserver, :logging, :add_audit_log],
      %{action: audit_log.action},
      %{log_id: audit_log.id}
    )

    {:ok, audit_log}
  end

  defp maybe_emit_event(v), do: v

  @doc """
  Updates a audit_log.

  ## Examples

      iex> update_audit_log(audit_log, %{field: new_value})
      {:ok, %AuditLog{}}

      iex> update_audit_log(audit_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_audit_log(AuditLog.t(), map) :: {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  def update_audit_log(%AuditLog{} = audit_log, attrs) do
    audit_log
    |> AuditLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a audit_log.

  ## Examples

      iex> delete_audit_log(audit_log)
      {:ok, %AuditLog{}}

      iex> delete_audit_log(audit_log)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_audit_log(AuditLog.t()) :: {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  def delete_audit_log(%AuditLog{} = audit_log) do
    Repo.delete(audit_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking audit_log changes.

  ## Examples

      iex> change_audit_log(audit_log)
      %Ecto.Changeset{data: %AuditLog{}}

  """
  @spec change_audit_log(AuditLog.t(), map) :: Ecto.Changeset.t()
  def change_audit_log(%AuditLog{} = audit_log, attrs \\ %{}) do
    AuditLog.changeset(audit_log, attrs)
  end
end
