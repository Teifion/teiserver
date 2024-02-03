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

  # Matches
  alias Teiserver.Game.{Match, MatchLib, MatchQueries}

  @doc false
  @spec match_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate match_query(args), to: MatchQueries

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
  @spec get_match_membership!(MatchMembership.id()) :: MatchMembership.t()
  @spec get_match_membership!(MatchMembership.id(), Teiserver.query_args()) :: MatchMembership.t()
  defdelegate get_match_membership!(match_membership_id, query_args \\ []), to: MatchMembershipLib

  @doc section: :match_membership
  @spec get_match_membership(MatchMembership.id()) :: MatchMembership.t() | nil
  @spec get_match_membership(MatchMembership.id(), Teiserver.query_args()) ::
          MatchMembership.t() | nil
  defdelegate get_match_membership(match_membership_id, query_args \\ []), to: MatchMembershipLib

  @doc section: :match_membership
  @spec create_match_membership(map) :: {:ok, MatchMembership.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_match_membership(attrs), to: MatchMembershipLib

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
  @spec get_match_setting!(MatchSetting.id()) :: MatchSetting.t()
  @spec get_match_setting!(MatchSetting.id(), Teiserver.query_args()) :: MatchSetting.t()
  defdelegate get_match_setting!(match_setting_id, query_args \\ []), to: MatchSettingLib

  @doc section: :match_setting
  @spec get_match_setting(MatchSetting.id()) :: MatchSetting.t() | nil
  @spec get_match_setting(MatchSetting.id(), Teiserver.query_args()) :: MatchSetting.t() | nil
  defdelegate get_match_setting(match_setting_id, query_args \\ []), to: MatchSettingLib

  @doc section: :match_setting
  @spec create_match_setting(map) :: {:ok, MatchSetting.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_match_setting(attrs), to: MatchSettingLib

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
