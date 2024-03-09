defmodule Teiserver.Migrations.Postgres.V01 do
  @moduledoc false
  # Copied and tweaked from Oban

  use Ecto.Migration

  @spec up(map) :: any
  def up(%{create_schema: create?, prefix: prefix} = opts) do
    %{escaped_prefix: _escaped, quoted_prefix: quoted} = opts

    if create?, do: execute("CREATE SCHEMA IF NOT EXISTS #{quoted};")

    execute("CREATE EXTENSION IF NOT EXISTS citext")

    # Clustering
    create table(:teiserver_cluster_members, primary_key: false, prefix: prefix) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:host, :string, null: false)

      timestamps()
    end

    # Accounts
    create_if_not_exists table(:account_users, primary_key: false, prefix: prefix) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:name, :string)
      add(:email, :string)
      add(:password, :string)

      add(:groups, {:array, :string})
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

      add(:smurf_of_id, references(:account_users, on_delete: :nothing, type: :uuid))

      timestamps()
    end

    # execute "CREATE INDEX IF NOT EXISTS lower_username ON #{prefix}.account_users (LOWER(name))"
    create_if_not_exists(unique_index(:account_users, [:email], prefix: prefix))

    create_if_not_exists table(:account_extra_user_data, primary_key: false, prefix: prefix) do
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid),
        primary_key: true,
        type: :uuid
      )

      add(:data, :jsonb)
    end

    # Game
    create_if_not_exists table(:game_match_types, prefix: prefix) do
      add(:name, :string)
    end

    create_if_not_exists table(:game_matches, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:name, :string)
      add(:tags, :jsonb)
      add(:public?, :boolean)
      add(:rated?, :boolean)

      add(:game_name, :string)
      add(:game_version, :string)

      add(:winning_team, :integer)
      add(:team_count, :integer)
      add(:team_size, :integer)
      add(:processed?, :boolean, default: false)
      add(:ended_normally?, :boolean)

      add(:lobby_opened_at, :utc_datetime)
      add(:match_started_at, :utc_datetime)
      add(:match_ended_at, :utc_datetime)

      add(:match_duration_seconds, :integer)

      add(:host_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:type_id, references(:game_match_types, on_delete: :nothing))

      timestamps()
    end

    create_if_not_exists table(:game_match_memberships, primary_key: false) do
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid),
        primary_key: true,
        type: :uuid
      )

      add(:match_id, references(:game_matches, on_delete: :nothing, type: :uuid),
        primary_key: true,
        type: :uuid
      )

      add(:team_number, :integer)

      add(:win?, :boolean, default: nil, null: true)

      add(:left_after_seconds, :integer)
      add(:party_id, :string)
    end

    create_if_not_exists table(:game_match_setting_types) do
      add(:name, :string)
    end

    create_if_not_exists table(:game_match_settings, primary_key: false) do
      add(:type_id, references(:game_match_setting_types, on_delete: :nothing), primary_key: true)

      add(:match_id, references(:game_matches, on_delete: :nothing, type: :uuid),
        primary_key: true,
        type: :uuid
      )

      add(:value, :string)
    end

    # Communications
    create_if_not_exists table(:communication_rooms, prefix: prefix) do
      add(:name, :string)
      timestamps()
    end

    create_if_not_exists table(:communication_room_messages, prefix: prefix) do
      add(:content, :text)
      add(:inserted_at, :utc_datetime)

      add(:sender_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:room_id, references(:communication_rooms, on_delete: :nothing))
    end

    create_if_not_exists table(:communication_direct_messages, prefix: prefix) do
      add(:content, :text)
      add(:inserted_at, :utc_datetime)
      add(:delivered?, :boolean)
      add(:read?, :boolean)

      add(:from_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:to_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
    end

    create_if_not_exists table(:communication_match_messages, prefix: prefix) do
      add(:content, :text)
      add(:inserted_at, :utc_datetime)

      add(:sender_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)
      add(:match_id, references(:game_matches, on_delete: :nothing, type: :uuid), type: :uuid)
    end

    # Settings
    create_if_not_exists table(:settings_server_settings, primary_key: false, prefix: prefix) do
      add(:key, :string, primary_key: true)
      add(:value, :string)

      timestamps()
    end

    create_if_not_exists table(:settings_user_setting_type, prefix: prefix) do
      add(:key, :string)
      add(:value, :string)
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)

      timestamps()
    end

    create_if_not_exists table(:settings_user_settings, prefix: prefix) do
      add(:key, :string)
      add(:value, :string)
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)

      timestamps()
    end

    create(index(:settings_user_settings, [:user_id], prefix: prefix))
  end

  def down(%{prefix: prefix, quoted_prefix: _quoted}) do
    # Comms
    drop_if_exists(table(:communication_room_messages, prefix: prefix))
    drop_if_exists(table(:communication_rooms, prefix: prefix))
    drop_if_exists(table(:communication_direct_messages, prefix: prefix))
    drop_if_exists(table(:communication_match_messages, prefix: prefix))

    # Game
    drop_if_exists(table(:game_match_memberships, prefix: prefix))
    drop_if_exists(table(:game_match_settings, prefix: prefix))
    drop_if_exists(table(:game_match_setting_types, prefix: prefix))
    drop_if_exists(table(:game_matches, prefix: prefix))
    drop_if_exists(table(:game_match_types, prefix: prefix))

    # Config
    drop_if_exists(table(:settings_server_settings, prefix: prefix))
    drop_if_exists(table(:settings_user_setting_type, prefix: prefix))
    drop_if_exists(table(:settings_user_settings, prefix: prefix))

    # Accounts
    drop_if_exists(table(:account_extra_user_data, prefix: prefix))
    drop_if_exists(table(:account_users, prefix: prefix))

    # System
    drop_if_exists(table(:teiserver_cluster_members, prefix: prefix))

    execute("DROP EXTENSION IF EXISTS citext")
  end
end
