defmodule Teiserver.Case do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias Teiserver.Test.Repo

  using do
    quote do
      # stream_data library
      # use ExUnitProperties

      import Teiserver.Case

      alias Teiserver.Config
      alias Teiserver.Test.Repo
    end
  end

  setup context do
    if context[:unboxed] do
      # Do stuff here
    else
      pid = Sandbox.start_owner!(Repo, shared: not context[:async])

      on_exit(fn -> Sandbox.stop_owner(pid) end)
    end

    :ok
  end
end
