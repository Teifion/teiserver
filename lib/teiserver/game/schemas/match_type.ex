defmodule Teiserver.Game.MatchType do
  @moduledoc """
  # MatchType
  Details for each type of match

  ### Attributes
  * `:name` - The name of the type
  """
  use TeiserverMacros, :schema

  schema "game_match_types" do
    field(:name, :string)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          id: id(),
          name: String.t()
        }

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(name)a)
    |> validate_required(~w(name)a)
    |> unique_constraint(~w(name)a)
  end
end
