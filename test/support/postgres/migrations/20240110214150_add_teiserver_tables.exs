defmodule Teiserver.Test.Repo.Postgres.Migrations.AddTeiseverTables do
  @moduledoc false
  use Ecto.Migration

  defdelegate up, to: Teiserver.Migrations

  def down do
    Teiserver.Migrations.down(version: 1)
  end
end
