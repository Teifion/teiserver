defmodule Teiserver.Account do
  @moduledoc """
  The contextual module for:
  - `Teiserver.Account.User`
  - `Teiserver.Account.ExtraUserData`
  - `Teiserver.Account.Relationship`
  - `Teiserver.Account.Friend`
  - `Teiserver.Account.FriendRequest`
  - `Teiserver.Account.Achievement`
  - `Teiserver.Account.AchievementType`
  """

  alias Teiserver.Account.{User, UserLib, UserQueries}

  @doc false
  @spec user_topic(Teiserver.user_id() | User.t()) :: String.t()
  defdelegate user_topic(user_or_user_id), to: UserLib

  @doc false
  @spec user_query(Teiserver.query_args()) :: Ecto.Query.t()
  defdelegate user_query(args), to: UserQueries

  @doc section: :user
  @spec list_users(list) :: [User.t()]
  defdelegate list_users(args), to: UserLib

  @doc section: :user
  @spec get_user!(Teiserver.user_id()) :: User.t()
  @spec get_user!(Teiserver.user_id(), Teiserver.query_args()) :: User.t()
  defdelegate get_user!(user_id, query_args \\ []), to: UserLib

  @doc section: :user
  @spec get_user(Teiserver.user_id()) :: User.t() | nil
  @spec get_user(Teiserver.user_id(), Teiserver.query_args()) :: User.t() | nil
  defdelegate get_user(user_id, query_args \\ []), to: UserLib

  @doc section: :user
  @spec get_user_by_id(Teiserver.user_id()) :: User.t() | nil
  defdelegate get_user_by_id(user_id), to: UserLib

  @doc section: :user
  @spec get_user_by_name(String.t()) :: User.t() | nil
  defdelegate get_user_by_name(name), to: UserLib

  @doc section: :user
  @spec get_user_by_email(String.t()) :: User.t() | nil
  defdelegate get_user_by_email(email), to: UserLib

  @doc section: :user
  @spec create_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_user(attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec register_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate register_user(attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec update_user(User, map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_user(user, attrs), to: UserLib

  @doc section: :user
  @spec update_password(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_password(user, attrs), to: UserLib

  @doc section: :user
  @spec update_limited_user(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_limited_user(user, attrs), to: UserLib

  @doc section: :user
  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_user(user), to: UserLib

  @doc section: :user
  @spec change_user(User.t(), map) :: Ecto.Changeset.t()
  defdelegate change_user(user, attrs \\ %{}), to: UserLib

  @doc section: :user
  @spec valid_password?(User.t(), String.t()) :: boolean
  defdelegate valid_password?(user, plaintext_password), to: UserLib

  @doc section: :user
  @spec generate_password() :: String.t()
  defdelegate generate_password(), to: UserLib

  @doc section: :user
  @spec allow?(Teiserver.user_id() | User.t(), [String.t()] | String.t()) :: boolean
  defdelegate allow?(user_or_user_id, permission_or_permissions), to: UserLib

  @doc section: :user
  @spec restricted?(Teiserver.user_id() | User.t(), [String.t()] | String.t()) :: boolean
  defdelegate restricted?(user_or_user_id, permission_or_permissions), to: UserLib

  @doc section: :user
  @spec user_name_acceptable?(String.t()) :: boolean
  defdelegate user_name_acceptable?(name), to: UserLib

  # Relationships
  # Friends
  # FriendRequests

  # AchievementTypes
  # Achievements
end
