defmodule Teiserver.Game.MatchMembershipLib do
  @moduledoc """
  TODO: Library of match_membership related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{MatchMembership, MatchMembershipQueries}

  @doc """
  Returns the list of match_memberships.

  ## Examples

      iex> list_match_memberships()
      [%MatchMembership{}, ...]

  """
  @spec list_match_memberships(Teiserver.query_args()) :: [MatchMembership.t()]
  def list_match_memberships(query_args) do
    query_args
    |> MatchMembershipQueries.match_membership_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_membership.

  Raises `Ecto.NoResultsError` if the MatchMembership does not exist.

  ## Examples

      iex> get_match_membership!(123)
      %MatchMembership{}

      iex> get_match_membership!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_membership!(MatchMembership.id()) :: MatchMembership.t()
  @spec get_match_membership!(MatchMembership.id(), Teiserver.query_args()) :: MatchMembership.t()
  def get_match_membership!(match_membership_id, query_args \\ []) do
    (query_args ++ [id: match_membership_id])
    |> MatchMembershipQueries.match_membership_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_membership.

  Returns nil if the MatchMembership does not exist.

  ## Examples

      iex> get_match_membership(123)
      %MatchMembership{}

      iex> get_match_membership(456)
      nil

  """
  @spec get_match_membership(MatchMembership.id()) :: MatchMembership.t() | nil
  @spec get_match_membership(MatchMembership.id(), Teiserver.query_args()) ::
          MatchMembership.t() | nil
  def get_match_membership(match_membership_id, query_args \\ []) do
    (query_args ++ [id: match_membership_id])
    |> MatchMembershipQueries.match_membership_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_membership.

  ## Examples

      iex> create_match_membership(%{field: value})
      {:ok, %MatchMembership{}}

      iex> create_match_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_membership(map) :: {:ok, MatchMembership.t()} | {:error, Ecto.Changeset.t()}
  def create_match_membership(attrs) do
    %MatchMembership{}
    |> MatchMembership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_membership.

  ## Examples

      iex> update_match_membership(match_membership, %{field: new_value})
      {:ok, %MatchMembership{}}

      iex> update_match_membership(match_membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_membership(MatchMembership.t(), map) ::
          {:ok, MatchMembership.t()} | {:error, Ecto.Changeset.t()}
  def update_match_membership(%MatchMembership{} = match_membership, attrs) do
    match_membership
    |> MatchMembership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_membership.

  ## Examples

      iex> delete_match_membership(match_membership)
      {:ok, %MatchMembership{}}

      iex> delete_match_membership(match_membership)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_membership(MatchMembership.t()) ::
          {:ok, MatchMembership.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_membership(%MatchMembership{} = match_membership) do
    Repo.delete(match_membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_membership changes.

  ## Examples

      iex> change_match_membership(match_membership)
      %Ecto.Changeset{data: %MatchMembership{}}

  """
  @spec change_match_membership(MatchMembership.t(), map) :: Ecto.Changeset.t()
  def change_match_membership(%MatchMembership{} = match_membership, attrs \\ %{}) do
    MatchMembership.changeset(match_membership, attrs)
  end
end
