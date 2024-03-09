defmodule Teiserver.Game do
  @moduledoc """
  The contextual module for:
  - `Teiserver.Game.Lobby`
  - `Teiserver.Game.Match`
  - `Teiserver.Game.MatchMembership`
  - `Teiserver.Game.MatchSettingType`
  - `Teiserver.Game.MatchSetting`
  - `Teiserver.Game.MatchResult`
  - `Teiserver.Game.ServerManagedLobby`
  """

  # Lobbies
  alias Teiserver.Game.{Lobby, LobbyLib, LobbySummary}

  @doc false
  @spec lobby_topic(Lobby.id()) :: String.t()
  defdelegate lobby_topic(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec subscribe_to_lobby(Lobby.id() | Lobby.t()) :: :ok
  defdelegate subscribe_to_lobby(lobby_or_lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec unsubscribe_from_lobby(Lobby.id() | Lobby.t()) :: :ok
  defdelegate unsubscribe_from_lobby(lobby_or_lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec get_lobby(Lobby.id()) :: Lobby.t() | nil
  defdelegate get_lobby(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec get_lobby_summary(Lobby.id()) :: LobbySummary.t() | nil
  defdelegate get_lobby_summary(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec get_lobby_attribute(Lobby.id(), atom()) :: any()
  defdelegate get_lobby_attribute(lobby_id, key), to: LobbyLib

  @doc section: :lobby
  @spec update_lobby(Lobby.id(), map) :: :ok | nil
  defdelegate update_lobby(lobby_id, value_map), to: LobbyLib

  @doc section: :lobby
  @spec list_lobby_ids() :: [Lobby.id()]
  defdelegate list_lobby_ids, to: LobbyLib

  @doc section: :lobby
  @spec list_local_lobby_ids() :: [Lobby.id()]
  defdelegate list_local_lobby_ids, to: LobbyLib

  @doc section: :lobby
  @spec list_lobby_summaries() :: [LobbySummary.t()]
  defdelegate list_lobby_summaries(), to: LobbyLib

  @doc section: :lobby
  @spec list_lobby_summaries([Lobby.id()]) :: [LobbySummary.t()]
  defdelegate list_lobby_summaries(lobby_ids), to: LobbyLib

  @doc section: :lobby
  @spec open_lobby(Teiserver.user_id(), Lobby.name()) :: {:ok, Lobby.id()} | {:error, String.t()}
  defdelegate open_lobby(host_id, name), to: LobbyLib

  @doc section: :lobby
  @spec cycle_lobby(Lobby.id()) :: :ok
  defdelegate cycle_lobby(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec lobby_start_match(Lobby.id()) :: :ok
  defdelegate lobby_start_match(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec close_lobby(Lobby.id()) :: :ok
  defdelegate close_lobby(lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec can_add_client_to_lobby?(Teiserver.user_id(), Lobby.id()) :: boolean()
  defdelegate can_add_client_to_lobby?(user_id, lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec add_client_to_lobby(Teiserver.user_id(), Lobby.id()) :: :ok | {:error, String.t()}
  defdelegate add_client_to_lobby(user_id, lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec remove_client_from_lobby(Teiserver.user_id(), Lobby.id()) :: :ok | nil
  defdelegate remove_client_from_lobby(user_id, lobby_id), to: LobbyLib

  @doc section: :lobby
  @spec lobby_name_acceptable?(String.t()) :: boolean
  defdelegate lobby_name_acceptable?(name), to: LobbyLib

  @doc false
  @spec start_lobby_server(Teiserver.user_id(), Lobby.name()) :: {:ok, Lobby.id()}
  defdelegate start_lobby_server(host_id, name), to: LobbyLib

  @doc false
  @spec lobby_exists?(Lobby.id()) :: pid() | boolean
  defdelegate lobby_exists?(lobby_id), to: LobbyLib

  #   @doc false
  #   @spec get_lobby_pid(Lobby.id()) :: pid() | nil
  #   defdelegate get_lobby_pid(lobby_id), to: LobbyLib

  #   @doc false
  #   @spec cast_lobby(Lobby.id(), any) :: any | nil
  #   defdelegate cast_lobby(lobby_id, message), to: LobbyLib

  #   @doc false
  #   @spec call_lobby(Lobby.id(), any) :: any | nil
  #   defdelegate call_lobby(lobby_id, message), to: LobbyLib

  @doc false
  @spec stop_lobby_server(Lobby.id()) :: :ok | nil
  defdelegate stop_lobby_server(lobby_id), to: LobbyLib

  # MatchTypes
  alias Teiserver.Game.{MatchType, MatchTypeLib, MatchTypeQueries}

  @doc false
  @spec match_type_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate match_type_query(args), to: MatchTypeQueries

  @doc section: :match_type
  @spec list_match_types(Teiserver.query_args()) :: [MatchType.t()]
  defdelegate list_match_types(args), to: MatchTypeLib

  @doc section: :match_type
  @spec get_match_type!(MatchType.id()) :: MatchType.t()
  @spec get_match_type!(MatchType.id(), Teiserver.query_args()) ::
          MatchType.t()
  defdelegate get_match_type!(match_type_id, query_args \\ []),
    to: MatchTypeLib

  @doc section: :match_type
  @spec get_match_type(MatchType.id()) :: MatchType.t() | nil
  @spec get_match_type(MatchType.id(), Teiserver.query_args()) ::
          MatchType.t() | nil
  defdelegate get_match_type(match_type_id, query_args \\ []),
    to: MatchTypeLib

  @doc section: :match_type
  @spec create_match_type(map) ::
          {:ok, MatchType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_match_type(attrs), to: MatchTypeLib

  @doc section: :match_type
  @spec get_or_create_match_type(String.t()) :: MatchType.id()
  defdelegate get_or_create_match_type(name), to: MatchTypeLib

  @doc section: :match_type
  @spec update_match_type(MatchType, map) ::
          {:ok, MatchType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_match_type(match_type, attrs), to: MatchTypeLib

  @doc section: :match_type
  @spec delete_match_type(MatchType.t()) ::
          {:ok, MatchType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_match_type(match_type), to: MatchTypeLib

  @doc section: :match_type
  @spec change_match_type(MatchType.t()) :: Ecto.Changeset.t()
  @spec change_match_type(MatchType.t(), map) :: Ecto.Changeset.t()
  defdelegate change_match_type(match_type, attrs \\ %{}), to: MatchTypeLib

  # Matches
  alias Teiserver.Game.{Match, MatchLib, MatchQueries}

  @doc false
  @spec match_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate match_query(args), to: MatchQueries

  @doc section: :match
  @spec start_match(Lobby.t()) :: Match.t()
  defdelegate start_match(lobby), to: MatchLib

  @doc section: :match
  @spec end_match(Match.id(), map()) :: Match.t()
  defdelegate end_match(match_id, outcome), to: MatchLib

  @doc section: :match
  @spec list_matches(Teiserver.query_args()) :: [Match.t()]
  defdelegate list_matches(args), to: MatchLib

  @doc section: :match
  @spec get_match!(Match.id()) :: Match.t()
  @spec get_match!(Match.id(), Teiserver.query_args()) :: Match.t()
  defdelegate get_match!(match_id, query_args \\ []), to: MatchLib

  @doc section: :match
  @spec get_match(Match.id()) :: Match.t() | nil
  @spec get_match(Match.id(), Teiserver.query_args()) :: Match.t() | nil
  defdelegate get_match(match_id, query_args \\ []), to: MatchLib

  @doc section: :match
  @spec create_match(map) :: {:ok, Match.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_match(attrs), to: MatchLib

  @doc section: :match
  @spec update_match(Match, map) :: {:ok, Match.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_match(match, attrs), to: MatchLib

  @doc section: :match
  @spec delete_match(Match.t()) :: {:ok, Match.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_match(match), to: MatchLib

  @doc section: :match
  @spec change_match(Match.t()) :: Ecto.Changeset.t()
  @spec change_match(Match.t(), map) :: Ecto.Changeset.t()
  defdelegate change_match(match, attrs \\ %{}), to: MatchLib

  # MatchMemberships
  alias Teiserver.Game.{MatchMembership, MatchMembershipLib, MatchMembershipQueries}

  @doc false
  @spec match_membership_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate match_membership_query(args), to: MatchMembershipQueries

  @doc section: :match_membership
  @spec list_match_memberships(Teiserver.query_args()) :: [MatchMembership.t()]
  defdelegate list_match_memberships(args), to: MatchMembershipLib

  @doc section: :match_membership
  @spec get_match_membership!(Teiserver.match_id(), Teiserver.user_id()) :: MatchMembership.t()
  @spec get_match_membership!(Teiserver.match_id(), Teiserver.user_id(), Teiserver.query_args()) ::
          MatchMembership.t()
  defdelegate get_match_membership!(match_id, user_id, query_args \\ []), to: MatchMembershipLib

  @doc section: :match_membership
  @spec get_match_membership(Teiserver.match_id(), Teiserver.user_id()) ::
          MatchMembership.t() | nil
  @spec get_match_membership(Teiserver.match_id(), Teiserver.user_id(), Teiserver.query_args()) ::
          MatchMembership.t() | nil
  defdelegate get_match_membership(match_id, user_id, query_args \\ []), to: MatchMembershipLib

  @doc section: :match_membership
  @spec create_match_membership(map) :: {:ok, MatchMembership.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_match_membership(attrs), to: MatchMembershipLib

  @doc section: :match_memberships
  @spec create_many_match_memberships([map]) ::
          {:ok, MatchMembership.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_many_match_memberships(attr_list), to: MatchMembershipLib

  @doc section: :match_membership
  @spec update_match_membership(MatchMembership, map) ::
          {:ok, MatchMembership.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_match_membership(match_membership, attrs), to: MatchMembershipLib

  @doc section: :match_membership
  @spec delete_match_membership(MatchMembership.t()) ::
          {:ok, MatchMembership.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_match_membership(match_membership), to: MatchMembershipLib

  @doc section: :match_membership
  @spec change_match_membership(MatchMembership.t()) :: Ecto.Changeset.t()
  @spec change_match_membership(MatchMembership.t(), map) :: Ecto.Changeset.t()
  defdelegate change_match_membership(match_membership, attrs \\ %{}), to: MatchMembershipLib

  # MatchSettingTypes
  alias Teiserver.Game.{MatchSettingType, MatchSettingTypeLib, MatchSettingTypeQueries}

  @doc false
  @spec match_setting_type_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate match_setting_type_query(args), to: MatchSettingTypeQueries

  @doc section: :match_setting_type
  @spec list_match_setting_types(Teiserver.query_args()) :: [MatchSettingType.t()]
  defdelegate list_match_setting_types(args), to: MatchSettingTypeLib

  @doc section: :match_setting_type
  @spec get_match_setting_type!(MatchSettingType.id()) :: MatchSettingType.t()
  @spec get_match_setting_type!(MatchSettingType.id(), Teiserver.query_args()) ::
          MatchSettingType.t()
  defdelegate get_match_setting_type!(match_setting_type_id, query_args \\ []),
    to: MatchSettingTypeLib

  @doc section: :match_setting_type
  @spec get_match_setting_type(MatchSettingType.id()) :: MatchSettingType.t() | nil
  @spec get_match_setting_type(MatchSettingType.id(), Teiserver.query_args()) ::
          MatchSettingType.t() | nil
  defdelegate get_match_setting_type(match_setting_type_id, query_args \\ []),
    to: MatchSettingTypeLib

  @doc section: :match_setting_type
  @spec create_match_setting_type(map) ::
          {:ok, MatchSettingType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_match_setting_type(attrs), to: MatchSettingTypeLib

  @doc section: :match_setting_type
  @spec get_or_create_match_setting_type(String.t()) :: MatchSettingType.id()
  defdelegate get_or_create_match_setting_type(name), to: MatchSettingTypeLib

  @doc section: :match_setting_type
  @spec update_match_setting_type(MatchSettingType, map) ::
          {:ok, MatchSettingType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_match_setting_type(match_setting_type, attrs), to: MatchSettingTypeLib

  @doc section: :match_setting_type
  @spec delete_match_setting_type(MatchSettingType.t()) ::
          {:ok, MatchSettingType.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_match_setting_type(match_setting_type), to: MatchSettingTypeLib

  @doc section: :match_setting_type
  @spec change_match_setting_type(MatchSettingType.t()) :: Ecto.Changeset.t()
  @spec change_match_setting_type(MatchSettingType.t(), map) :: Ecto.Changeset.t()
  defdelegate change_match_setting_type(match_setting_type, attrs \\ %{}), to: MatchSettingTypeLib

  # MatchSettings
  alias Teiserver.Game.{MatchSetting, MatchSettingLib, MatchSettingQueries}

  @doc false
  @spec match_setting_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate match_setting_query(args), to: MatchSettingQueries

  @doc section: :match_setting
  @spec list_match_settings(Teiserver.query_args()) :: [MatchSetting.t()]
  defdelegate list_match_settings(args), to: MatchSettingLib

  @doc section: :match_setting
  @spec get_match_settings_map(Teiserver.match_id()) :: %{String.t() => String.t()}
  defdelegate get_match_settings_map(match_id), to: MatchSettingLib

  @doc section: :match_setting
  @spec get_match_setting!(Teiserver.match_id(), MatchSettingType.id()) :: MatchSetting.t()
  @spec get_match_setting!(Teiserver.match_id(), MatchSettingType.id(), Teiserver.query_args()) ::
          MatchSetting.t()
  defdelegate get_match_setting!(match_id, setting_type_id, query_args \\ []), to: MatchSettingLib

  @doc section: :match_setting
  @spec get_match_setting(Teiserver.match_id(), MatchSettingType.id()) ::
          MatchSetting.t() | nil
  @spec get_match_setting(Teiserver.match_id(), MatchSettingType.id(), Teiserver.query_args()) ::
          MatchSetting.t() | nil
  defdelegate get_match_setting(match_id, setting_type_id, query_args \\ []), to: MatchSettingLib

  @doc section: :match_setting
  @spec create_match_setting(map) :: {:ok, MatchSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_match_setting(attrs), to: MatchSettingLib

  @doc section: :match_settings
  @spec create_many_match_settings([map]) ::
          {:ok, MatchSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_many_match_settings(attr_list), to: MatchSettingLib

  @doc section: :match_setting
  @spec update_match_setting(MatchSetting, map) ::
          {:ok, MatchSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_match_setting(match_setting, attrs), to: MatchSettingLib

  @doc section: :match_setting
  @spec delete_match_setting(MatchSetting.t()) ::
          {:ok, MatchSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_match_setting(match_setting), to: MatchSettingLib

  @doc section: :match_setting
  @spec change_match_setting(MatchSetting.t()) :: Ecto.Changeset.t()
  @spec change_match_setting(MatchSetting.t(), map) :: Ecto.Changeset.t()
  defdelegate change_match_setting(match_setting, attrs \\ %{}), to: MatchSettingLib

  # Match results/stats/extra data
  # Game data file stuff (e.g. unit data if added by devs)
  # Server Managed Lobbies
end
