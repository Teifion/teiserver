defmodule Teiserver.Game.MatchSetting do
  @moduledoc """
  # MatchSetting
  Settings applied to matches

  ### Attributes
  * `:type_id`/`:type` - The type of setting
  * `:match_id`/`:match` - The match the setting was used for
  * `:value` - The value of the setting

  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "game_match_settings" do
    belongs_to(:type, Teiserver.Game.MatchSettingType, primary_key: true)
    belongs_to(:match, Teiserver.Game.Match, primary_key: true, type: Ecto.UUID)

    field(:value, :string)
  end

  @type t :: %__MODULE__{
          type_id: Teiserver.Game.MatchSettingType.id(),
          match_id: Teiserver.match_id(),
          value: String.t()
        }

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(type_id match_id value)a)
    |> validate_required(~w(type_id match_id value)a)
    |> unique_constraint(~w(type_id match_id)a)
  end
end
