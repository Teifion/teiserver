defmodule Teiserver.Account do
  @moduledoc """

  """

  alias Teiserver.Account.UserLib

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  @spec list_users() :: [User]
  defdelegate list_users(), to: UserLib

  @spec list_users(list) :: [User]
  defdelegate list_users(args), to: UserLib

  @spec get_user!(non_neg_integer()) :: User.t()
  defdelegate get_user!(user_id), to: UserLib

  @spec get_user!(non_neg_integer(), list) :: User.t() | nil
  defdelegate get_user!(user_id, args), to: UserLib

  @spec get_user(non_neg_integer()) :: User.t() | nil
  defdelegate get_user(user_id), to: UserLib

  @spec get_user(non_neg_integer(), list) :: User.t() | nil
  defdelegate get_user(user_id, args), to: UserLib

  @spec create_user() :: {:ok, User} | {:error, Ecto.Changeset}
  defdelegate create_user(), to: UserLib

  @spec create_user(map) :: {:ok, User} | {:error, Ecto.Changeset}
  defdelegate create_user(attrs), to: UserLib

  @spec update_user(User, map) :: {:ok, User} | {:error, Ecto.Changeset}
  defdelegate update_user(user, attrs), to: UserLib

  @spec delete_user(User) :: {:ok, User} | {:error, Ecto.Changeset}
  defdelegate delete_user(user), to: UserLib

  @spec change_user(User) :: Ecto.Changeset
  defdelegate change_user(user), to: UserLib

  @spec change_user(User, map) :: Ecto.Changeset
  defdelegate change_user(user, attrs), to: UserLib
end
