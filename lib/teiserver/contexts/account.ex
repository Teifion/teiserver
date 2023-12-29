defmodule Teiserver.Account do
  @moduledoc """
  The contextual module for [Users](Teiserver.Account.User), [ExtraUserData](Teiserver.Account.ExtraUserData)
  """

  alias Teiserver.Account.{User, UserLib}

  @spec list_users() :: [User.t]
  defdelegate list_users(), to: UserLib

  @spec list_users(list) :: [User.t]
  defdelegate list_users(args), to: UserLib

  @spec get_user!(non_neg_integer()) :: User.t
  defdelegate get_user!(user_id), to: UserLib

  @spec get_user!(non_neg_integer(), list) :: User.t | nil
  defdelegate get_user!(user_id, args), to: UserLib

  @spec get_user(non_neg_integer()) :: User.t | nil
  defdelegate get_user(user_id), to: UserLib

  @spec get_user(non_neg_integer(), list) :: User.t | nil
  defdelegate get_user(user_id, args), to: UserLib

  @spec create_user() :: {:ok, User.t} | {:error, Ecto.Changeset}
  @spec create_user(map) :: {:ok, User.t} | {:error, Ecto.Changeset}
  @doc delegate_to: {UserLib, :create_user, 1}
  defdelegate create_user(attrs \\ %{}), to: UserLib

  @spec update_user(User, map) :: {:ok, User.t} | {:error, Ecto.Changeset}
  defdelegate update_user(user, attrs), to: UserLib

  @spec delete_user(User.t) :: {:ok, User.t} | {:error, Ecto.Changeset}
  @doc delegate_to: {UserLib, :delete_user, 1}
  defdelegate delete_user(user), to: UserLib

  @spec change_user(User.t) :: Ecto.Changeset
  defdelegate change_user(user), to: UserLib

  @spec change_user(User.t, map) :: Ecto.Changeset
  defdelegate change_user(user, attrs), to: UserLib
end
