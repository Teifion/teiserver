defmodule TeiserverMacros do
  @moduledoc """
  A set of macros for defining common file types.

  This can be used in your application as:

      use TeiserverMacros, :queries
      use TeiserverMacros, :library
  """

  def queries do
    quote do
      import Ecto.Query, warn: false
      import Teiserver.Helpers.QueryMacros
      alias Teiserver.Helpers.QueryHelper
      alias Teiserver.Repo
    end
  end

  def library do
    quote do
      alias Teiserver.Repo
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias Teiserver.Helpers.SchemaHelper
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
