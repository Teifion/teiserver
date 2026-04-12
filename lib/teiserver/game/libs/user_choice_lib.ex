defmodule Teiserver.Game.UserChoiceLib do
  @moduledoc """
  TODO: Library of user_choice related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Game.{UserChoice, UserChoiceQueries, UserChoiceType}

  @doc """
  Returns the list of user_choices.

  ## Examples

      iex> list_user_choices()
      [%UserChoice{}, ...]

  """
  @spec list_user_choices(Teiserver.query_args()) :: [UserChoice.t()]
  def list_user_choices(query_args) do
    query_args
    |> UserChoiceQueries.user_choice_query()
    |> Repo.all()
  end

  @doc """
  Returns a key => value map of match choices for a given match_id.

  ## Examples

      iex> get_user_choices_map(123)
      %{"key1" => "value1", "key2" => "value2"}

      iex> get_user_choices_map(456)
      %{}

  """
  @spec get_user_choices_map(Teiserver.match_id(), Teiserver.user_id()) :: %{
          String.t() => String.t()
        }
  def get_user_choices_map(match_id, user_id) do
    list_user_choices(where: [match_id: match_id, user_id: user_id], preload: [:type])
    |> Map.new(fn ms ->
      {ms.type.name, ms.value}
    end)
  end

  @doc """
  Gets a single user_choice.

  Raises `Ecto.NoResultsError` if the UserChoice does not exist.

  ## Examples

      iex> get_user_choice!("29a42cef-2239-4a1d-8359-947310647a3b", "74e27850-f16f-4981-9077-ea0ddd4a0d8a", 123)
      %UserChoice{}

      iex> get_user_choice!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_choice!(
          Teiserver.match_id(),
          Teiserver.user_id(),
          UserChoiceType.id(),
          Teiserver.query_args()
        ) ::
          UserChoice.t()
  def get_user_choice!(match_id, user_id, choice_type_id, query_args \\ []) do
    (query_args ++ [match_id: match_id, user_id: user_id, choice_type_id: choice_type_id])
    |> UserChoiceQueries.user_choice_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single user_choice.

  Returns nil if the UserChoice does not exist.

  ## Examples

      iex> get_user_choice(123)
      %UserChoice{}

      iex> get_user_choice(456)
      nil

  """
  @spec get_user_choice(
          Teiserver.match_id(),
          Teiserver.user_id(),
          UserChoiceType.id(),
          Teiserver.query_args()
        ) ::
          UserChoice.t() | nil
  def get_user_choice(match_id, user_id, choice_type_id, query_args \\ []) do
    (query_args ++ [match_id: match_id, user_id: user_id, choice_type_id: choice_type_id])
    |> UserChoiceQueries.user_choice_query()
    |> Repo.one()
  end

  @doc """
  Creates a user_choice.

  ## Examples

      iex> create_user_choice(%{field: value})
      {:ok, %UserChoice{}}

      iex> create_user_choice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user_choice(map) :: {:ok, UserChoice.t()} | {:error, Ecto.Changeset.t()}
  def create_user_choice(attrs) do
    %UserChoice{}
    |> UserChoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates many user_choices. Not unlike most other create functions this will raise an exception on failure and should not be caught using the normal case functions.

  Expects a map of values which can be turned into valid match choices.

  ## Examples

      iex> create_many_user_choices([%{field: value}])
      {:ok, %UserChoice{}}

      iex> create_many_user_choices([%{field: bad_value}])
      raise Postgrex.Error

  """
  @spec create_many_user_choices([map]) :: {:ok, map}
  def create_many_user_choices(attr_list) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(:insert_all, UserChoice, attr_list)
    |> Teiserver.Repo.transaction()
  end

  @doc """
  Updates a user_choice.

  ## Examples

      iex> update_user_choice(user_choice, %{field: new_value})
      {:ok, %UserChoice{}}

      iex> update_user_choice(user_choice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user_choice(UserChoice.t(), map) ::
          {:ok, UserChoice.t()} | {:error, Ecto.Changeset.t()}
  def update_user_choice(%UserChoice{} = user_choice, attrs) do
    user_choice
    |> UserChoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_choice.

  ## Examples

      iex> delete_user_choice(user_choice)
      {:ok, %UserChoice{}}

      iex> delete_user_choice(user_choice)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user_choice(UserChoice.t()) ::
          {:ok, UserChoice.t()} | {:error, Ecto.Changeset.t()}
  def delete_user_choice(%UserChoice{} = user_choice) do
    Repo.delete(user_choice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_choice changes.

  ## Examples

      iex> change_user_choice(user_choice)
      %Ecto.Changeset{data: %UserChoice{}}

  """
  @spec change_user_choice(UserChoice.t(), map) :: Ecto.Changeset.t()
  def change_user_choice(%UserChoice{} = user_choice, attrs \\ %{}) do
    UserChoice.changeset(user_choice, attrs)
  end
end
