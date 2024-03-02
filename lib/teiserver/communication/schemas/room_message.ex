defmodule Teiserver.Communication.RoomMessage do
  @moduledoc """
  # RoomMessage
  A message sent sender a user into a chat room.

  ### Attributes

  * `:content` - The (textual) contents of the message
  * `:inserted_at` - The time the message was inserted
  * `:sender_id` - The `Teiserver.Account.User` who sent the message
  * `:room_id` - The id of the `Teiserver.Communication.Room` the message was sent in
  """
  use TeiserverMacros, :schema

  @derive {Jason.Encoder, only: ~w(content inserted_at sender_id room_id)a}
  schema "communication_room_messages" do
    field(:content, :string)
    field(:inserted_at, :utc_datetime)

    belongs_to(:sender, Teiserver.Account.User, type: Ecto.UUID)
    belongs_to(:room, Teiserver.Communication.Room)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          id: id(),
          content: String.t(),
          inserted_at: DateTime.t(),
          sender_id: Teiserver.user_id(),
          room_id: Teiserver.Communication.Room.id()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(content inserted_at sender_id room_id)a)
    |> validate_required(~w(content inserted_at sender_id room_id)a)
  end
end
