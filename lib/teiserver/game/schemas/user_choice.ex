defmodule Teiserver.Game.UserChoice do
  @moduledoc """
  # UserChoice
  Choices made by users at the onset of a match. Not to be confused with `Teiserver.Settings.UserSetting` which is a general preference.

  ### Attributes
  * `:type_id`/`:type` - The type of choice
  * `:match_id`/`:match` - The match the choice was made in
  * `:user_id`/`:user` - The user the choice was made by
  * `:value` - The value of the choice
  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "game_user_choices" do
    belongs_to(:type, Teiserver.Game.UserChoiceType, primary_key: true)
    belongs_to(:match, Teiserver.Game.Match, primary_key: true, type: Ecto.UUID)
    belongs_to(:user, Teiserver.Account.User, primary_key: true, type: Ecto.UUID)

    field(:value, :string)
  end

  @type t :: %__MODULE__{
          type_id: Teiserver.Game.UserChoiceType.id(),
          match_id: Teiserver.match_id(),
          user_id: Teiserver.user_id(),
          value: String.t()
        }

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(type_id match_id user_id value)a)
    |> validate_required(~w(type_id match_id user_id value)a)
    |> unique_constraint(~w(type_id match_id user_id)a)
  end
end
