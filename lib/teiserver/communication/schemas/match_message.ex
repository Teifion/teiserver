defmodule Teiserver.Communication.MatchMessage do
  @moduledoc """
  # MatchMessage
  A message sent either in a lobby or in a game and mirrored in the lobby

  ### Attributes

  * `:content` - The (textual) contents of the message
  * `:inserted_at` - The time the message was inserted
  * `:sender_id` - The `Teiserver.Account.User` who sent the message
  * `:match_id` - The id of the `Teiserver.Game.Match` the message was sent in
  """
  use TeiserverMacros, :schema

  schema "communication_match_messages" do
    field(:content, :string)
    field(:inserted_at, :utc_datetime)

    belongs_to(:sender, Teiserver.Account.User)
    belongs_to(:match_id, Teiserver.Game.Match)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          id: id(),
          content: String.t(),
          inserted_at: DateTime.t(),
          sender_id: Teiserver.user_id(),
          match_id: Teiserver.Game.Match.id()
        }

  @doc false
  def changeset(server_setting, attrs \\ %{}) do
    server_setting
    |> cast(attrs, ~w(content inserted_at sender_id match_id)a)
    |> validate_required(~w(content inserted_at sender_id match_id)a)
  end
end
