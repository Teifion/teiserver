defmodule Teiserver.System.ClusterMemberLib do
  @moduledoc """
  Library of cluster_member related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.System.{ClusterMember, ClusterMemberQueries}

  @doc """
  Returns the list of cluster_members.

  ## Examples

      iex> list_cluster_members()
      [%ClusterMember{}, ...]

  """
  @spec list_cluster_members(Teiserver.query_args()) :: [ClusterMember.t()]
  def list_cluster_members(query_args \\ []) do
    query_args
    |> ClusterMemberQueries.cluster_member_query()
    |> Repo.all()
  end

  @doc """
  Gets a single cluster_member.

  Raises `Ecto.NoResultsError` if the ClusterMember does not exist.

  ## Examples

      iex> get_cluster_member!(123)
      %ClusterMember{}

      iex> get_cluster_member!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_cluster_member!(ClusterMember.id()) :: ClusterMember.t()
  @spec get_cluster_member!(ClusterMember.id(), Teiserver.query_args()) :: ClusterMember.t()
  def get_cluster_member!(cluster_member_id, query_args \\ []) do
    (query_args ++ [id: cluster_member_id])
    |> ClusterMemberQueries.cluster_member_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single cluster_member.

  Returns nil if the ClusterMember does not exist.

  ## Examples

      iex> get_cluster_member(123)
      %ClusterMember{}

      iex> get_cluster_member(456)
      nil

  """
  @spec get_cluster_member(ClusterMember.id()) :: ClusterMember.t() | nil
  @spec get_cluster_member(ClusterMember.id(), Teiserver.query_args()) :: ClusterMember.t() | nil
  def get_cluster_member(cluster_member_id, query_args \\ []) do
    (query_args ++ [id: cluster_member_id])
    |> ClusterMemberQueries.cluster_member_query()
    |> Repo.one()
  end

  @doc """
  Creates a cluster_member.

  ## Examples

      iex> create_cluster_member(%{field: value})
      {:ok, %ClusterMember{}}

      iex> create_cluster_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_cluster_member(map) :: {:ok, ClusterMember.t()} | {:error, Ecto.Changeset.t()}
  def create_cluster_member(attrs \\ %{}) do
    %ClusterMember{}
    |> ClusterMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cluster_member.

  ## Examples

      iex> update_cluster_member(cluster_member, %{field: new_value})
      {:ok, %ClusterMember{}}

      iex> update_cluster_member(cluster_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_cluster_member(ClusterMember.t(), map) ::
          {:ok, ClusterMember.t()} | {:error, Ecto.Changeset.t()}
  def update_cluster_member(%ClusterMember{} = cluster_member, attrs) do
    cluster_member
    |> ClusterMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cluster_member.

  ## Examples

      iex> delete_cluster_member(cluster_member)
      {:ok, %ClusterMember{}}

      iex> delete_cluster_member(cluster_member)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_cluster_member(ClusterMember.t()) ::
          {:ok, ClusterMember.t()} | {:error, Ecto.Changeset.t()}
  def delete_cluster_member(%ClusterMember{} = cluster_member) do
    Repo.delete(cluster_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cluster_member changes.

  ## Examples

      iex> change_cluster_member(cluster_member)
      %Ecto.Changeset{data: %ClusterMember{}}

  """
  @spec change_cluster_member(ClusterMember.t(), map) :: Ecto.Changeset.t()
  def change_cluster_member(%ClusterMember{} = cluster_member, attrs \\ %{}) do
    ClusterMember.changeset(cluster_member, attrs)
  end
end
