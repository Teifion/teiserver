defmodule Teiserver.Helpers.MapHelper do
  @moduledoc """
  Helper functions for maps
  """

  @doc """
  Returns a list of changes from m1 to m2. Does not handle deleted keys.
  """
  @spec map_diffs(map(), map()) :: map()
  def map_diffs(m1, m2) do
    Enum.uniq(Map.keys(m1) ++ Map.keys(m2))
      |> Enum.map(fn key ->
        v1 = Map.get(m1, key, nil)
        v2 = Map.get(m2, key, nil)

        if v1 != v2 do
          {key, v2}
        else
          nil
        end
      end)
      |> Enum.reject(&(&1 == nil))
      |> Map.new
  end
end
