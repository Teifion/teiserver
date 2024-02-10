defmodule Teiserver.Game.MatchSettingLib do
  @moduledoc """
  TODO: Library of match_setting related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{MatchSetting, MatchSettingQueries, MatchSettingType}

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
  Returns a key => value map of match settings for a given match_id.

  ## Examples

      iex> get_match_settings_map(123)
      %{"key1" => "value1", "key2" => "value2"}

      iex> get_match_settings_map(456)
      %{}

  """
  @spec get_match_settings_map(Teiserver.match_id()) :: %{String.t() => String.t()}
  def get_match_settings_map(match_id) do
    list_match_settings(where: [match_id: match_id], preload: [:type])
    |> Map.new(fn ms ->
      {ms.type.name, ms.value}
    end)
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
  @spec get_match_setting!(Teiserver.match_id(), MatchSettingType.id()) :: MatchSetting.t()
  @spec get_match_setting!(Teiserver.match_id(), MatchSettingType.id(), Teiserver.query_args()) ::
          MatchSetting.t()
  def get_match_setting!(match_id, setting_type_id, query_args \\ []) do
    (query_args ++ [match_id: match_id, setting_type_id: setting_type_id])
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
  @spec get_match_setting(Teiserver.match_id(), MatchSettingType.id()) ::
          MatchSetting.t() | nil
  @spec get_match_setting(Teiserver.match_id(), MatchSettingType.id(), Teiserver.query_args()) ::
          MatchSetting.t() | nil
  def get_match_setting(match_id, setting_type_id, query_args \\ []) do
    (query_args ++ [match_id: match_id, setting_type_id: setting_type_id])
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
  Creates many match_settings. Not unlike most other create functions this will raise an exception on failure and should not be caught using the normal case functions.

  Expects a map of values which can be turned into valid match settings.

  ## Examples

      iex> create_many_match_settings([%{field: value}])
      {:ok, %MatchSetting{}}

      iex> create_many_match_settings([%{field: bad_value}])
      raise Postgrex.Error

  """
  @spec create_many_match_settings([map]) :: {:ok, map}
  def create_many_match_settings(attr_list) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, MatchSetting, attr_list)
    |> Teiserver.Repo.transaction()
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
