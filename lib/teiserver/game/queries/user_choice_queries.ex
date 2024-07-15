defmodule Teiserver.Game.UserChoiceQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Game.UserChoice
  require Logger

  @spec user_choice_query(Teiserver.query_args()) :: Ecto.Query.t()
  def user_choice_query(args) do
    query = from(user_choices in UserChoice)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_where(args[:search])
    |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), atom(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :match_id, match_ids) do
    from(user_choices in query,
      where: user_choices.match_id in ^List.wrap(match_ids)
    )
  end

  def _where(query, :user_id, user_ids) do
    from(user_choices in query,
      where: user_choices.user_id in ^List.wrap(user_ids)
    )
  end

  def _where(query, :type_id, type_ids) do
    from(user_choices in query,
      where: user_choices.type_id in ^List.wrap(type_ids)
    )
  end

  def _where(query, :value, value) do
    from(user_choices in query,
      where: user_choices.value in ^List.wrap(value)
    )
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Value (A-Z)") do
    from(user_choices in query,
      order_by: [asc: user_choices.value]
    )
  end

  def _order_by(query, "Value (Z-A)") do
    from(user_choices in query,
      order_by: [desc: user_choices.value]
    )
  end

  @spec do_preload(Ecto.Query.t(), list() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :type) do
    from(user_choices in query,
      left_join: types in assoc(user_choices, :type),
      preload: [type: types]
    )
  end

  def _preload(query, :match) do
    from(user_choices in query,
      left_join: matches in assoc(user_choices, :match),
      preload: [match: matches]
    )
  end
end
