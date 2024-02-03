defmodule Teiserver.Game.MatchSettingLib do
  @moduledoc """
  TODO: Library of match_setting related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{MatchSetting, MatchSettingQueries}

  @doc """
  Returns the list of match_settings.

  ## Examples

      iex> list_match_settings()
      [%MatchSetting{}, ...]

  """
  @spec list_match_settings(Teiserver.query_args()) :: [MatchSetting.t()]
  def list_match_settings(query_args) do
    query_args
    |> MatchSettingQueries.match_setting_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_setting.

  Raises `Ecto.NoResultsError` if the MatchSetting does not exist.

  ## Examples

      iex> get_match_setting!(123)
      %MatchSetting{}

      iex> get_match_setting!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_setting!(MatchSetting.id()) :: MatchSetting.t()
  @spec get_match_setting!(MatchSetting.id(), Teiserver.query_args()) :: MatchSetting.t()
  def get_match_setting!(match_setting_id, query_args \\ []) do
    (query_args ++ [id: match_setting_id])
    |> MatchSettingQueries.match_setting_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_setting.

  Returns nil if the MatchSetting does not exist.

  ## Examples

      iex> get_match_setting(123)
      %MatchSetting{}

      iex> get_match_setting(456)
      nil

  """
  @spec get_match_setting(MatchSetting.id()) :: MatchSetting.t() | nil
  @spec get_match_setting(MatchSetting.id(), Teiserver.query_args()) :: MatchSetting.t() | nil
  def get_match_setting(match_setting_id, query_args \\ []) do
    (query_args ++ [id: match_setting_id])
    |> MatchSettingQueries.match_setting_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_setting.

  ## Examples

      iex> create_match_setting(%{field: value})
      {:ok, %MatchSetting{}}

      iex> create_match_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_setting(map) :: {:ok, MatchSetting.t()} | {:error, Ecto.Changeset.t()}
  def create_match_setting(attrs) do
    %MatchSetting{}
    |> MatchSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_setting.

  ## Examples

      iex> update_match_setting(match_setting, %{field: new_value})
      {:ok, %MatchSetting{}}

      iex> update_match_setting(match_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_setting(MatchSetting.t(), map) ::
          {:ok, MatchSetting.t()} | {:error, Ecto.Changeset.t()}
  def update_match_setting(%MatchSetting{} = match_setting, attrs) do
    match_setting
    |> MatchSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_setting.

  ## Examples

      iex> delete_match_setting(match_setting)
      {:ok, %MatchSetting{}}

      iex> delete_match_setting(match_setting)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_setting(MatchSetting.t()) ::
          {:ok, MatchSetting.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_setting(%MatchSetting{} = match_setting) do
    Repo.delete(match_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_setting changes.

  ## Examples

      iex> change_match_setting(match_setting)
      %Ecto.Changeset{data: %MatchSetting{}}

  """
  @spec change_match_setting(MatchSetting.t(), map) :: Ecto.Changeset.t()
  def change_match_setting(%MatchSetting{} = match_setting, attrs \\ %{}) do
    MatchSetting.changeset(match_setting, attrs)
  end
end
