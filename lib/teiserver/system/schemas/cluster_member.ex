defmodule Teiserver.System.ClusterMember do
  @moduledoc """
  # Match
  A clustering method making use of a database to setup and update the cluster.

  ### Attributes

  * `:host` - The host name, e.g. "server1.host.co.uk"

  """
  use TeiserverMacros, :schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "teiserver_cluster_members" do
    field(:host, :string)

    timestamps()
  end

  @type id :: Ecto.UUID.t()

  @type t :: %__MODULE__{
          id: id(),
          host: String.t()
        }

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(host)a)
    |> validate_required(~w(host)a)
  end
end
