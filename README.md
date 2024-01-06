<p align="center">
  Elixir middleware server designed for running games.<br />
  Focused on facilitating connectivity, the library is engine and game agnostic.
</p>

<p align="center">
  <a href="https://hex.pm/packages/teiserver">
    <img alt="Hex Version" src="https://img.shields.io/hexpm/v/teiserver.svg">
  </a>

  <a href="https://hexdocs.pm/teiserver">
    <img alt="Hex Docs" src="http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat">
  </a>

  <a href="https://opensource.org/licenses/Apache-2.0">
    <img alt="Apache 2 License" src="https://img.shields.io/hexpm/l/teiserver">
  </a>
</p>

_Note: This README is for the unreleased main branch, please reference the
[official documentation on hexdocs][hexdoc] for the latest stable release._

[hexdoc]: https://hexdocs.pm/teiserver/Teiserver.html

## Installation
First add to your dependencies in `mix.exs`.
```elixir
def deps do
  [
    {:teiserver, "~> 0.1.0"}
  ]
end
```

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

Add this to your Application supervision tree:
```elixir
children = [
  {Teiserver, Application.get_env(:my_app, Teiserver)}
]
```
