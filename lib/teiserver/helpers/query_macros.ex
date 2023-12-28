defmodule Teiserver.Helpers.QueryMacros do
  @moduledoc false

  defmacro lower(field) do
    quote do
      fragment("LOWER(?)", unquote(field))
    end
  end

  defmacro between(field, low, high) do
    quote do
      fragment("? BETWEEN ? AND ?", unquote(field), unquote(low), unquote(high))
    end
  end

  defmacro array_remove(field, value) do
    quote do
      fragment("array_remove(?, ?)", unquote(field), unquote(value))
    end
  end

  defmacro array_agg(field) do
    quote do
      fragment("array_agg(?)", unquote(field))
    end
  end

  defmacro array_overlap_a_in_b(a, b) do
    quote do
      fragment("? \\?| ?", unquote(a), unquote(b))
    end
  end
end
