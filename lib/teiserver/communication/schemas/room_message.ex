defmodule Teiserver.Communication.RoomMessage do
  @moduledoc """
  # RoomMessage
  A message sent from a user into a chat room.

  ### Attributes

  * `:content` - The (textual) contents of the message
  * `:inserted_at` - The time the message was inserted
  * `:from_id` - The `Teiserver.Account.User` who sent the message
  * `:room_id` - The id of the `Teiserver.Communication.Room` the message was sent in
  """
  use TeiserverMacros, :schema

  schema "communication_room_messages" do
    field(:content, :string)
    field(:inserted_at, :utc_datetime)

    belongs_to(:from, Teiserver.Account.User)
    belongs_to(:room, Teiserver.Communication.Room)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
    id: id(),
    content: String.t(),
    inserted_at: DateTime.t(),

    from_id: Teiserver.user_id(),
    room_id: Teiserver.Communication.Room.id()
  }

  @doc false
  def changeset(server_setting, attrs \\ %{}) do
    server_setting
    |> cast(attrs, ~w(content inserted_at from_id room_id)a)
    |> validate_required(~w(content inserted_at from_id room_id)a)
  end
end
