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
  def list_users(query_args \\ []) do
    conf = Teiserver.config()
    query = UserQueries.query_users(query_args)
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
  @spec get_user!(non_neg_integer()) :: User.t
  def get_user!(user_id, query_args \\ []) do
    conf = Teiserver.config()
    query = UserQueries.query_users(query_args ++ [id: user_id])
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
  @spec get_user(non_neg_integer(), list) :: User.t | nil
  def get_user(user_id, query_args \\ []) do
    conf = Teiserver.config()
    query = UserQueries.query_users(query_args ++ [id: user_id])
    Repo.one(conf, query)
  end

  @spec get_user_by_id(non_neg_integer()) :: User.t | nil
  def get_user_by_id(user_id) do
    conf = Teiserver.config()
    query = UserQueries.query_users([id: user_id, limit: 1])
    Repo.one(conf, query)
  end

  @spec get_user_by_name(String.t) :: User.t | nil
  def get_user_by_name(name) do
    conf = Teiserver.config()
    query = UserQueries.query_users([where: [name_lower: name], limit: 1])
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
  @spec update_user(User, map) :: {:ok, User.t} | {:error, Ecto.Changeset}
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
  @spec delete_user(User.t) :: {:ok, User.t} | {:error, Ecto.Changeset}
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
  @spec change_user(User.t, map) :: Ecto.Changeset
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs, :full)
  end

  @doc """
  Takes a user, a plaintext password and returns a boolean if the password is
  correct for the user. Note it does this via a secure method to prevent timing
  attacks, never manually verify the password with standard string comparison.
  """
  @spec verify_user_password(User.t, String.t) :: boolean
  def verify_user_password(user, plaintext_password) do
    User.verify_password(plaintext_password, user.password)
  end
end
