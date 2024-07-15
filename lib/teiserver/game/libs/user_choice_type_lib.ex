defmodule Teiserver.Game.UserChoiceTypeLib do
  @moduledoc """
  TODO: Library of user_choice_type related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{UserChoiceType, UserChoiceTypeQueries}

  @doc """
  Returns the list of user_choice_types.

  ## Examples

      iex> list_user_choice_types()
      [%UserChoiceType{}, ...]

  """
  @spec list_user_choice_types(Teiserver.query_args()) :: [UserChoiceType.t()]
  def list_user_choice_types(query_args) do
    query_args
    |> UserChoiceTypeQueries.user_choice_type_query()
    |> Repo.all()
  end

  @doc """
  Gets a single user_choice_type.

  Raises `Ecto.NoResultsError` if the UserChoiceType does not exist.

  ## Examples

      iex> get_user_choice_type!(123)
      %UserChoiceType{}

      iex> get_user_choice_type!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_choice_type!(UserChoiceType.id(), Teiserver.query_args()) ::
          UserChoiceType.t()
  def get_user_choice_type!(user_choice_type_id, query_args \\ []) do
    (query_args ++ [id: user_choice_type_id])
    |> UserChoiceTypeQueries.user_choice_type_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single user_choice_type.

  Returns nil if the UserChoiceType does not exist.

  ## Examples

      iex> get_user_choice_type(123)
      %UserChoiceType{}

      iex> get_user_choice_type(456)
      nil

  """
  @spec get_user_choice_type(UserChoiceType.id(), Teiserver.query_args()) ::
          UserChoiceType.t() | nil
  def get_user_choice_type(user_choice_type_id, query_args \\ []) do
    (query_args ++ [id: user_choice_type_id])
    |> UserChoiceTypeQueries.user_choice_type_query()
    |> Repo.one()
  end

  @doc """
  Creates a user_choice_type.

  ## Examples

      iex> create_user_choice_type(%{field: value})
      {:ok, %UserChoiceType{}}

      iex> create_user_choice_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user_choice_type(map) ::
          {:ok, UserChoiceType.t()} | {:error, Ecto.Changeset.t()}
  def create_user_choice_type(attrs) do
    %UserChoiceType{}
    |> UserChoiceType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets the ID of a user_choice_type, if the type doesn't exist
  it will create the user_choice_type and return the id of that type

  ## Examples

      iex> get_or_create_user_choice_type_id("existing")
      123

      iex> get_or_create_user_choice_type_id("non-existing")
      1234

  """
  @spec get_or_create_user_choice_type_id(String.t()) :: UserChoiceType.id()
  def get_or_create_user_choice_type_id(name) do
    case Cachex.get(:ts_user_choice_type_lookup, name) do
      {:ok, nil} ->
        result = do_get_or_create_user_choice_type_id(name)
        Cachex.put(:ts_user_choice_type_lookup, name, result)
        result

      {:ok, value} ->
        value
    end

  end

  @spec do_get_or_create_user_choice_type_id(String.t()) :: UserChoiceType.id()
  def do_get_or_create_user_choice_type_id(name) do
    name = String.trim(name)

    query =
      UserChoiceTypeQueries.user_choice_type_query(
        where: [name: name],
        select: [:id],
        order_by: ["Name (A-Z)"]
      )

    case Repo.all(query) do
      [] ->
        {:ok, user_choice_type} =
          %UserChoiceType{}
          |> UserChoiceType.changeset(%{name: name})
          |> Repo.insert()

        user_choice_type.id

      [%{id: id} | _] ->
        id
    end
  end

  @doc """
  Updates a user_choice_type.

  ## Examples

      iex> update_user_choice_type(user_choice_type, %{field: new_value})
      {:ok, %UserChoiceType{}}

      iex> update_user_choice_type(user_choice_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user_choice_type(UserChoiceType.t(), map) ::
          {:ok, UserChoiceType.t()} | {:error, Ecto.Changeset.t()}
  def update_user_choice_type(%UserChoiceType{} = user_choice_type, attrs) do
    user_choice_type
    |> UserChoiceType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_choice_type.

  ## Examples

      iex> delete_user_choice_type(user_choice_type)
      {:ok, %UserChoiceType{}}

      iex> delete_user_choice_type(user_choice_type)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user_choice_type(UserChoiceType.t()) ::
          {:ok, UserChoiceType.t()} | {:error, Ecto.Changeset.t()}
  def delete_user_choice_type(%UserChoiceType{} = user_choice_type) do
    Repo.delete(user_choice_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_choice_type changes.

  ## Examples

      iex> change_user_choice_type(user_choice_type)
      %Ecto.Changeset{data: %UserChoiceType{}}

  """
  @spec change_user_choice_type(UserChoiceType.t(), map) :: Ecto.Changeset.t()
  def change_user_choice_type(%UserChoiceType{} = user_choice_type, attrs \\ %{}) do
    UserChoiceType.changeset(user_choice_type, attrs)
  end
end
