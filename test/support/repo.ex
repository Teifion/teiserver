defmodule Teiserver.Test.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :teiserver,
    adapter: Ecto.Adapters.Postgres
end

defmodule Teiserver.Test.DynamicRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :teiserver,
    adapter: Ecto.Adapters.Postgres

  def init(_, _) do
    {:ok, Teiserver.Test.Repo.config()}
  end
end

# defmodule Teiserver.Test.LiteRepo do
#   @moduledoc false

#   use Ecto.Repo, otp_app: :teiserver, adapter: Ecto.Adapters.SQLite3
# end

defmodule Teiserver.Test.UnboxedRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :teiserver,
    adapter: Ecto.Adapters.Postgres

  def init(_, _) do
    config = Teiserver.Test.Repo.config()

    {:ok, Keyword.delete(config, :pool)}
  end
end
