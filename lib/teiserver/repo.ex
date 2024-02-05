defmodule Teiserver.Repo do
  @moduledoc false

  @doc false
  @spec repo() :: Module
  defp repo do
    Application.get_env(:teiserver, :repo)
  end

  @spec all(Ecto.Query.t(), list) :: any
  def all(query, opts \\ []) do
    repo().all(query, opts)
  end

  @spec one(Ecto.Query.t(), list) :: any
  def one(query, opts \\ []) do
    repo().one(query, opts)
  end

  @spec one!(Ecto.Query.t(), list) :: any
  def one!(query, opts \\ []) do
    repo().one!(query, opts)
  end

  @spec insert(Ecto.Query.t(), list) :: any
  def insert(query, opts \\ []) do
    repo().insert(query, opts)
  end

  @spec insert!(Ecto.Query.t(), list) :: any
  def insert!(query, opts \\ []) do
    repo().insert!(query, opts)
  end

  @spec update(Ecto.Query.t(), list) :: any
  def update(query, opts \\ []) do
    repo().update(query, opts)
  end

  @spec delete(Ecto.Query.t(), list) :: any
  def delete(query, opts \\ []) do
    repo().delete(query, opts)
  end

  @spec transaction(Ecto.Query.t(), list) :: any
  def transaction(query, opts \\ []) do
    repo().transaction(query, opts)
  end
end
