defmodule Teiserver.Logging.AuditLog do
  @moduledoc """
  # AuditLog
  Description here

  ### Attributes

  * `:action` - The action performed which generated the audit log
  * `:details` - A key-value store of extra details related to the action
  * `:ip` - The IP address of the sender of the command (if available)
  * `:user` - The user who performed the action
  """
  use TeiserverMacros, :schema

  schema "audit_logs" do
    field(:action, :string)
    field(:details, :map)
    field(:ip, :string)
    belongs_to(:user, Teiserver.Account.User, type: Ecto.UUID)

    timestamps(type: :utc_datetime)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          id: id(),
          action: String.t(),
          details: map(),
          ip: String.t(),
          user_id: Teiserver.user_id()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(action details ip user_id)a)
    |> validate_required(~w(action details)a)
  end
end
