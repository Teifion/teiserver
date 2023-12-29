defmodule Teiserver.Account.UserLib do
  @moduledoc """
  Library of user related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Account.{User, UserQueries}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  @spec list_users(list) :: list
  def list_users(args \\ []) do
    conf = Teiserver.config()
    query = UserQueries.query_users(args)
    Repo.all(conf, query)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(non_neg_integer()) :: User.t()
  def get_user!(user_id, args \\ []) do
    conf = Teiserver.config()
    query = UserQueries.query_users(args ++ [id: user_id])
    Repo.one!(conf, query)
  end

  @doc """
  Gets a single user.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  @spec get_user(non_neg_integer(), list) :: User.t() | nil
  def get_user(user_id, args \\ []) do
    conf = Teiserver.config()
    query = UserQueries.query_users(args ++ [id: user_id])
    Repo.one(conf, query)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user() :: {:ok, User.t} | {:error, Ecto.Changeset}
  @spec create_user(map) :: {:ok, User.t} | {:error, Ecto.Changeset}
  def create_user(attrs \\ %{}) do
    conf = Teiserver.config()
    changeset = User.changeset(%User{}, attrs, :full)
    Repo.insert(conf, changeset)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    conf = Teiserver.config()
    changeset = User.changeset(user, attrs, :full)
    Repo.update(conf, changeset)
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    conf = Teiserver.config()
    Repo.delete(conf, user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs, :full)
  end
end
