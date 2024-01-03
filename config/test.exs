import Config

# This makes anything in our tests involving user passwords (creating or logging in) much faster
config :argon2_elixir, t_cost: 1, m_cost: 8

config :teiserver, Teiserver.Test.Repo,
  database: "teiserver_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :teiserver,
  repo: Teiserver.Test.Repo
