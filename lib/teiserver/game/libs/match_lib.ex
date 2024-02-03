defmodule Teiserver.Game.MatchLib do
  @moduledoc """
  TODO: Library of match related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{Match, MatchQueries}

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  @spec list_matches(Teiserver.query_args()) :: [Match.t()]
  def list_matches(query_args) do
    query_args
    |> MatchQueries.match_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match!(Match.id()) :: Match.t()
  @spec get_match!(Match.id(), Teiserver.query_args()) :: Match.t()
  def get_match!(match_id, query_args \\ []) do
    (query_args ++ [id: match_id])
    |> MatchQueries.match_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match.

  Returns nil if the Match does not exist.

  ## Examples

      iex> get_match(123)
      %Match{}

      iex> get_match(456)
      nil

  """
  @spec get_match(Match.id()) :: Match.t() | nil
  @spec get_match(Match.id(), Teiserver.query_args()) :: Match.t() | nil
  def get_match(match_id, query_args \\ []) do
    (query_args ++ [id: match_id])
    |> MatchQueries.match_query()
    |> Repo.one()
  end

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match(map) :: {:ok, Match.t()} | {:error, Ecto.Changeset.t()}
  def create_match(attrs) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match(Match.t(), map) :: {:ok, Match.t()} | {:error, Ecto.Changeset.t()}
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match(Match.t()) :: {:ok, Match.t()} | {:error, Ecto.Changeset.t()}
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  @spec change_match(Match.t(), map) :: Ecto.Changeset.t()
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end
end
