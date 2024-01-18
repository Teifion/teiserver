defmodule Teiserver.Communication.Room do
  @moduledoc """
  # Room
  An object representing a chat room.

  ### Attributes

  * `:name` - The room name
  """
  use TeiserverMacros, :schema

  schema "communication_rooms" do
    field(:name, :string)

    timestamps()
  end

  @type id :: non_neg_integer()
  @type name :: String.t()
  @type name_or_id :: name() | id()

  @type t :: %__MODULE__{
          id: id(),
          name: name(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(server_setting, attrs \\ %{}) do
    server_setting
    |> cast(attrs, ~w(name)a)
    |> validate_required(~w(name)a)
  end
end
