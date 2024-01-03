defmodule Teiserver.Test.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :teiserver,
    adapter: Ecto.Adapters.Postgres
end
