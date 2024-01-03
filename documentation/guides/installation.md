# Installation
A middleware server library.

## Dependency
First add to your dependencies in `mix.exs`.
```elixir
def deps do
  [
    {:teiserver, "~> 0.0.2"}
  ]
end
```

## Migration
Now add a migration
```bash
mix ecto.gen.migration add_teiserver_tables
```

Open the generated migration and add the below code:
```elixir
defmodule MyApp.Repo.Migrations.AddTeiserverTables do
  use Ecto.Migration

  def up do
    Teiserver.Migration.up()
  end

  # We specify `version: 1` in `down`, ensuring that we'll roll all the way back down if
  # necessary, regardless of which version we've migrated `up` to.
  def down do
    Teiserver.Migration.down(version: 1)
  end
end
```

## Supervision tree
Add this to your Application supervision tree:
```elixir
children = [
  {Teiserver, Application.get_env(:my_app, Teiserver)}
]
```

## Config
In `config.exs`
```elixir
config :teiserver,
  repo: MyApp.Repo
```

