defmodule Teiserver.Migrations.Postgres.V01 do
  @moduledoc false
  # Copied and tweaked from Oban

  use Ecto.Migration

  def up(%{create_schema: create?, prefix: prefix} = opts) do
    %{escaped_prefix: _escaped, quoted_prefix: quoted} = opts

    if create?, do: execute("CREATE SCHEMA IF NOT EXISTS #{quoted};")

    execute("CREATE EXTENSION IF NOT EXISTS citext")

    # Accounts
    create_if_not_exists table(:account_users, prefix: prefix) do
      add(:name, :string)
      add(:email, :string)
      add(:password, :string)

      add(:roles, {:array, :string})
      add(:permissions, {:array, :string})

      add(:trust_score, :integer)
      add(:behaviour_score, :integer)
      add(:social_score, :integer)

      add(:last_login_at, :utc_datetime)
      add(:last_logout_at, :utc_datetime)
      add(:last_played_at, :utc_datetime)

      add(:restrictions, {:array, :string}, default: [])
      add(:restricted_until, :utc_datetime)

      add(:shadow_banned?, :boolean, default: false)

      add(:smurf_of_id, references(:account_users, on_delete: :nothing))

      timestamps()
    end

    # execute "CREATE INDEX IF NOT EXISTS lower_username ON #{prefix}.account_users (LOWER(name))"
    create_if_not_exists(unique_index(:account_users, [:email], prefix: prefix))

    create_if_not_exists table(:account_extra_user_data, primary_key: false, prefix: prefix) do
      add(:user_id, references(:account_users, on_delete: :nothing), primary_key: true)
      add(:data, :jsonb)
    end

    # Communications
    create_if_not_exists table(:communication_rooms, prefix: prefix) do
      add(:name, :string)
      timestamps()
    end

    create_if_not_exists table(:communication_room_messages, prefix: prefix) do
      add(:content, :text)
      add(:inserted_at, :utc_datetime)

      add(:sender_id, references(:account_users, on_delete: :nothing))
      add(:room_id, references(:communication_rooms, on_delete: :nothing))
    end

    create_if_not_exists table(:communication_direct_messages, prefix: prefix) do
      add(:content, :text)
      add(:inserted_at, :utc_datetime)
      add(:delivered?, :boolean)
      add(:read?, :boolean)

      add(:from_id, references(:account_users, on_delete: :nothing))
      add(:to_id, references(:account_users, on_delete: :nothing))
    end

    # Config
    create_if_not_exists table(:settings_server, primary_key: false, prefix: prefix) do
      add(:key, :string, primary_key: true)
      add(:value, :string)

      timestamps()
    end

    create table(:settings_user, prefix: prefix) do
      add(:key, :string)
      add(:value, :string)
      add(:user_id, references(:account_users, on_delete: :nothing))

      timestamps()
    end

    create(index(:settings_user, [:user_id], prefix: prefix))
  end

  def down(%{prefix: prefix, quoted_prefix: _quoted}) do
    execute("DROP EXTENSION IF EXISTS citext")

    # Accounts
    drop_if_exists(table(:account_users, prefix: prefix))
    drop_if_exists(table(:account_extra_user_data, prefix: prefix))

    # Config
    drop_if_exists(table(:settings_server, prefix: prefix))
    drop_if_exists(table(:settings_user, prefix: prefix))
  end
end
