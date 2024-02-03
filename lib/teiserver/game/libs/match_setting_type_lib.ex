defmodule Teiserver.Game.MatchSettingTypeLib do
  @moduledoc """
  TODO: Library of match_setting_type related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{MatchSettingType, MatchSettingTypeQueries}

  @doc """
  Returns the list of match_setting_types.

  ## Examples

      iex> list_match_setting_types()
      [%MatchSettingType{}, ...]

  """
  @spec list_match_setting_types(Teiserver.query_args()) :: [MatchSettingType.t()]
  def list_match_setting_types(query_args) do
    query_args
    |> MatchSettingTypeQueries.match_setting_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_setting_type.

  Raises `Ecto.NoResultsError` if the MatchSettingType does not exist.

  ## Examples

      iex> get_match_setting_type!(123)
      %MatchSettingType{}

      iex> get_match_setting_type!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_setting_type!(MatchSettingType.id()) :: MatchSettingType.t()
  @spec get_match_setting_type!(MatchSettingType.id(), Teiserver.query_args()) ::
          MatchSettingType.t()
  def get_match_setting_type!(match_setting_type_id, query_args \\ []) do
    (query_args ++ [id: match_setting_type_id])
    |> MatchSettingTypeQueries.match_setting_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_setting_type.

  Returns nil if the MatchSettingType does not exist.

  ## Examples

      iex> get_match_setting_type(123)
      %MatchSettingType{}

      iex> get_match_setting_type(456)
      nil

  """
  @spec get_match_setting_type(MatchSettingType.id()) :: MatchSettingType.t() | nil
  @spec get_match_setting_type(MatchSettingType.id(), Teiserver.query_args()) ::
          MatchSettingType.t() | nil
  def get_match_setting_type(match_setting_type_id, query_args \\ []) do
    (query_args ++ [id: match_setting_type_id])
    |> MatchSettingTypeQueries.match_setting_type_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_setting_type.

  ## Examples

      iex> create_match_setting_type(%{field: value})
      {:ok, %MatchSettingType{}}

      iex> create_match_setting_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_setting_type(map) ::
          {:ok, MatchSettingType.t()} | {:error, Ecto.Changeset.t()}
  def create_match_setting_type(attrs) do
    %MatchSettingType{}
    |> MatchSettingType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_setting_type.

  ## Examples

      iex> update_match_setting_type(match_setting_type, %{field: new_value})
      {:ok, %MatchSettingType{}}

      iex> update_match_setting_type(match_setting_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_setting_type(MatchSettingType.t(), map) ::
          {:ok, MatchSettingType.t()} | {:error, Ecto.Changeset.t()}
  def update_match_setting_type(%MatchSettingType{} = match_setting_type, attrs) do
    match_setting_type
    |> MatchSettingType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_setting_type.

  ## Examples

      iex> delete_match_setting_type(match_setting_type)
      {:ok, %MatchSettingType{}}

      iex> delete_match_setting_type(match_setting_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_setting_type(MatchSettingType.t()) ::
          {:ok, MatchSettingType.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_setting_type(%MatchSettingType{} = match_setting_type) do
    Repo.delete(match_setting_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_setting_type changes.

  ## Examples

      iex> change_match_setting_type(match_setting_type)
      %Ecto.Changeset{data: %MatchSettingType{}}

  """
  @spec change_match_setting_type(MatchSettingType.t(), map) :: Ecto.Changeset.t()
  def change_match_setting_type(%MatchSettingType{} = match_setting_type, attrs \\ %{}) do
    MatchSettingType.changeset(match_setting_type, attrs)
  end
end
