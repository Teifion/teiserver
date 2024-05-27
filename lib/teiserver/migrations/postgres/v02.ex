defmodule Teiserver.Migrations.Postgres.V02 do
  @moduledoc false
  # Copied and tweaked from Oban

  use Ecto.Migration

  @spec up(map) :: any
  def up(%{prefix: prefix}) do
    # Logging
    create_if_not_exists table(:audit_logs, prefix: prefix) do
      add(:action, :string)
      add(:details, :jsonb)
      add(:ip, :string)
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)

      timestamps()
    end
  end

  @spec down(map) :: any
  def down(%{prefix: prefix, quoted_prefix: _quoted}) do
    # Logging
    drop_if_exists(table(:audit_logs, prefix: prefix))
  end
end
