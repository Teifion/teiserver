defmodule Teiserver.Game.MatchLib do
  @moduledoc """
  TODO: Library of match related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{Match, MatchQueries, Lobby, MatchTypeLib}
  alias Teiserver.{Connections, Game}

  @doc """
  Given a lobby_id, will update the match, memberships and settings for that lobby
  and then update the Lobby itself to show the lobby is now in progress.
  """
  @spec start_match(Lobby.id()) :: Match.t()
  def start_match(lobby_id) do
    lobby = Game.get_lobby(lobby_id)
    match_id = lobby.match_id

    type_id = MatchTypeLib.calculate_match_type(lobby).id

    clients = Connections.get_client_list(lobby.members)

    teams =
      clients
      |> Enum.group_by(fn c -> c.team_number end)

    team_count =
      teams
      |> Map.keys()
      |> Enum.count()

    team_size =
      teams
      |> Enum.map(fn {_, team_members} -> Enum.count(team_members) end)
      |> Enum.max()

    {:ok, match} =
      match_id
      |> get_match!()
      |> update_match(%{
        name: lobby.name,
        tags: lobby.tags,
        public?: lobby.public?,
        rated?: lobby.rated?,
        game_name: lobby.game_name,
        game_version: lobby.game_version,
        team_count: team_count,
        team_size: team_size,
        match_started_at: Timex.now(),
        type_id: type_id
      })

    # Do members
    {:ok, _memberships} =
      clients
      |> Enum.map(fn client ->
        %{
          user_id: client.id,
          match_id: match.id,
          team_number: client.team_number,
          party_id: client.party_id
        }
      end)
      |> Game.create_many_match_memberships()

    # Do settings
    {:ok, _settings} =
      lobby.game_settings
      |> Enum.map(fn {key, value} ->
        type_id = Game.get_or_create_match_setting_type(key)
        %{type_id: type_id, match_id: match.id, value: value}
      end)
      |> Game.create_many_match_settings()

    # Tell the lobby server the match is starting
    Game.lobby_start_match(lobby_id)

    # Finally return the match itself
    match
  end

  @doc """
  Ends an ongoing match and updates memberships accordingly.

  Second argument is a map of the outcomes for the match with the following keys:
  * `:winning_team` - The team_number of the winning team
  * `:ended_normally?` - A boolean indicating if the match ended normally
  * `:players` - A map of player data with the keys being the user_id of the player and the value being a map of their specific outcome

  Player outcomes are expected to map like so:
  Required:

  Optional:
  * `:left_after_seconds` - The number of seconds after the start the player left if early. If not included it is assumed the player remained until the end.

  ## Examples

      iex> end_match(123, %{winning_team: 1, ended_normally?: true, player_data: %{123: }})
      %Match{}

  """
  @spec end_match(Match.id(), map()) :: Match.t()
  def end_match(match_id, outcome) when is_binary(match_id) do
    match = get_match!(match_id)
    now = Timex.now()

    duration_seconds = Timex.diff(match.match_started_at, now, :second)

    {:ok, updated_match} =
      update_match(match, %{
        winning_team: outcome.winning_team,
        ended_normally?: outcome.ended_normally?,
        match_ended_at: now,
        match_duration_seconds: duration_seconds
      })

    Game.list_match_memberships(where: [match_id: match.id])
    |> Enum.each(fn mm ->
      player_outcome = outcome.players[mm.user_id]

      win? = mm.team_number == outcome.winning_team

      attrs = %{
        win?: win?,
        left_after_seconds: Map.get(player_outcome, :left_after_seconds)
      }

      Game.update_match_membership(mm, attrs)
    end)

    # Finally return the updated match
    updated_match
  end

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
