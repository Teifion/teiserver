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
  url: System.get_env("DATABASE_URL") || "postgres://teiserver_test:123456789@localhost/teiserver_test"

config :teiserver,
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
