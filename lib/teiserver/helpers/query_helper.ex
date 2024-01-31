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

  @spec query_select(Ecto.Query.t(), String.t() | nil) :: Ecto.Query.t()
  def query_select(query, nil), do: query

  def query_select(query, fields) do
    from(stat_grids in query,
      select: ^fields
    )
  end
end
