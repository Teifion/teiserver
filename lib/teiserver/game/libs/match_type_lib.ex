defmodule Teiserver.Game.MatchTypeLib do
  @moduledoc """
  Library of match_type related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{MatchType, MatchTypeQueries, Lobby}

  @doc """

  """
  @spec calculate_match_type(Lobby.t()) :: MatchType.id()
  def calculate_match_type(%Lobby{} = lobby) do
    name =
      if Application.get_env(:teiserver, :fn_calculate_match_type) do
        f = Application.get_env(:teiserver, :fn_calculate_match_type)
        f.(lobby)
      else
        default_calculate_match_type(lobby)
      end

    get_or_create_match_type(name)
  end

  @doc """
  The default method used to define match types

  Can be over-ridden using the config [fn_calculate_match_type](config.html#fn_calculate_match_type)
  """
  @spec default_calculate_match_type(Lobby.t()) :: String.t()
  def default_calculate_match_type(lobby) do
    if Enum.count(lobby.members) == 2 do
      "Duel"
    else
      "Team"
    end
  end

  @doc """
  Returns the list of match_types.

  ## Examples

      iex> list_match_types()
      [%MatchType{}, ...]

  """
  @spec list_match_types(Teiserver.query_args()) :: [MatchType.t()]
  def list_match_types(query_args \\ []) do
    query_args
    |> MatchTypeQueries.match_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_type.

  Raises `Ecto.NoResultsError` if the MatchType does not exist.

  ## Examples

      iex> get_match_type!(123)
      %MatchType{}

      iex> get_match_type!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_type!(MatchType.id()) :: MatchType.t()
  @spec get_match_type!(MatchType.id(), Teiserver.query_args()) :: MatchType.t()
  def get_match_type!(match_type_id, query_args \\ []) do
    (query_args ++ [id: match_type_id])
    |> MatchTypeQueries.match_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_type.

  Returns nil if the MatchType does not exist.

  ## Examples

      iex> get_match_type(123)
      %MatchType{}

      iex> get_match_type(456)
      nil

  """
  @spec get_match_type(MatchType.id()) :: MatchType.t() | nil
  @spec get_match_type(MatchType.id(), Teiserver.query_args()) :: MatchType.t() | nil
  def get_match_type(match_type_id, query_args \\ []) do
    (query_args ++ [id: match_type_id])
    |> MatchTypeQueries.match_type_query()
    |> Repo.one()
  end

  @doc """
  Gets a single match_type by name or id (must be an integer).

  Returns nil if the MatchType does not exist.

  ## Examples

      iex> get_match_type_by_name_or_id("main")
      %MatchType{}

      iex> get_match_type_by_name_or_id(123)
      %MatchType{}

      iex> get_match_type_by_name_or_id("not a name")
      nil

      iex> get_match_type_by_name_or_id(456)
      nil

  """
  @spec get_match_type_by_name_or_id(String.t() | MatchType.id()) :: MatchType.t() | nil
  def get_match_type_by_name_or_id(match_type_id) when is_integer(match_type_id) do
    get_match_type(match_type_id)
  end

  def get_match_type_by_name_or_id(match_type_name) do
    MatchTypeQueries.match_type_query(where: [name: match_type_name])
    |> Repo.one()
  end

  @doc """
  Creates a match_type.

  ## Examples

      iex> create_match_type(%{field: value})
      {:ok, %MatchType{}}

      iex> create_match_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_type(map) :: {:ok, MatchType.t()} | {:error, Ecto.Changeset.t()}
  def create_match_type(attrs \\ %{}) do
    %MatchType{}
    |> MatchType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a match_type of a given name, if the match_type does not exist it is created.

  ## Examples

      iex> get_or_create_match_type("name")
      %MatchType{}

      iex> get_or_create_match_type("not a match_type"")
      %MatchType{}

  """
  @spec get_or_create_match_type(String.t()) :: MatchType.t()
  def get_or_create_match_type(match_type_name) do
    case get_match_type_by_name_or_id(match_type_name) do
      nil ->
        {:ok, match_type} = create_match_type(%{name: match_type_name})
        match_type

      match_type ->
        match_type
    end
  end

  @doc """
  Updates a match_type.

  ## Examples

      iex> update_match_type(match_type, %{field: new_value})
      {:ok, %MatchType{}}

      iex> update_match_type(match_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_type(MatchType.t(), map) ::
          {:ok, MatchType.t()} | {:error, Ecto.Changeset.t()}
  def update_match_type(%MatchType{} = match_type, attrs) do
    match_type
    |> MatchType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_type.

  ## Examples

      iex> delete_match_type(match_type)
      {:ok, %MatchType{}}

      iex> delete_match_type(match_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_type(MatchType.t()) :: {:ok, MatchType.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_type(%MatchType{} = match_type) do
    Repo.delete(match_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_type changes.

  ## Examples

      iex> change_match_type(match_type)
      %Ecto.Changeset{data: %MatchType{}}

  """
  @spec change_match_type(MatchType.t(), map) :: Ecto.Changeset.t()
  def change_match_type(%MatchType{} = match_type, attrs \\ %{}) do
    MatchType.changeset(match_type, attrs)
  end
end
