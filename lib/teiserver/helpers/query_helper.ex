defmodule Teiserver.Helpers.QueryHelper do
  @moduledoc false
  import Ecto.Query, warn: false

  @spec offset_query(Ecto.Query.t(), nil | Integer.t()) :: Ecto.Query.t()
  def offset_query(query, nil), do: query

  def offset_query(query, amount) do
    query
    |> offset(^amount)
  end

  @spec limit_query(Ecto.Query.t(), Integer.t() | :infinity) :: Ecto.Query.t()
  def limit_query(query, :infinity), do: query
  def limit_query(query, nil), do: query

  def limit_query(query, amount) do
    query
    |> limit(^amount)
  end

  @spec limit_query(Ecto.Query.t(), integer() | nil, integer() | nil) :: Ecto.Query.t()
  def limit_query(query, nil, max_amount), do: limit_query(query, max_amount)

  def limit_query(query, amount, max_amount) when is_integer(amount) do
    limit_query(query, min(amount, max_amount))
  end

  def limit_query(query, amount, max_amount) do
    limit_query(query, min(amount |> String.to_integer(), max_amount))
  end

  @spec query_select(Ecto.Query.t(), String.t() | nil) :: Ecto.Query.t()
  def query_select(query, nil), do: query

  def query_select(query, fields) do
    from(stat_grids in query,
      select: ^fields
    )
  end
end
