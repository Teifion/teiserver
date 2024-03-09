import Config

config :logger, level: :warning

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id]

config :teiserver, Teiserver.Test.Repo,
  migration_lock: false,
  name: Teiserver.Test.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/postgres",
  url:
    System.get_env("DATABASE_URL") ||
      "postgres://teiserver_test:123456789@localhost/teiserver_test"

config :teiserver,
  # Overridden by application
  client_destroy_timeout_seconds: 300,
  lobby_join_method: :simple,
  teiserver_clustering: true,
  teiserver_clustering_post_join_functions: [],

  # User defaults
  default_behaviour_score: 10_000,
  default_trust_score: 10_000,
  default_social_score: 10_000,

  # Used for tests
  ecto_repos: [Teiserver.Test.Repo]

# Import environment specific config
try do
  import_config "#{config_env()}.exs"
rescue
  _ in File.Error ->
    nil

  error ->
    reraise error, __STACKTRACE__
end
