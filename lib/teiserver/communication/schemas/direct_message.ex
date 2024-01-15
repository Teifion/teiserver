defmodule Teiserver.Communication.DirectMessage do
  @moduledoc """
  # DirectMessage
  A (text) message from one user to another.

  ### Attributes

  * `:content` - The text content of the message
  * `:inserted_at` - The datetime the message was sent
  * `:delivered?` - Tracks if the message has been delivered to the user or not
  * `:read?` - Tracks if the message has been read by the user or not
  * `:from_id` - The `Teiserver.Account.User` who sent the message
  * `:to_id` - The `Teiserver.Account.User` the message was sent to
  """
  use TeiserverMacros, :schema

  schema "communication_direct_messages" do
    field(:content, :string)
    field(:inserted_at, :utc_datetime)
    field(:delivered?, :boolean, default: false)
    field(:read?, :boolean, default: false)

    belongs_to(:from, Teiserver.Account.User)
    belongs_to(:to, Teiserver.Account.User)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          id: id(),
          content: String.t(),
          inserted_at: DateTime.t(),
          delivered?: boolean,
          read?: boolean,
          from_id: Teiserver.user_id(),
          to_id: Teiserver.user_id()
        }

  @doc false
  def changeset(server_setting, attrs \\ %{}) do
    server_setting
    |> cast(attrs, ~w(content inserted_at delivered? read? from_id to_id)a)
    |> validate_required(~w(content inserted_at delivered? read? from_id to_id)a)
  end
end
