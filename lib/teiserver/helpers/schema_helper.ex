defmodule Teiserver.Helpers.SchemaHelper do
  @moduledoc false

  @spec trim_strings(map, list | atom) :: map
  def trim_strings(params, fields) do
    fields =
      fields
      |> List.wrap()
      |> Enum.map(&Atom.to_string/1)

    params
    |> Map.new(fn {k, v} ->
      if Enum.member?(fields, k) do
        if v == nil do
          {k, nil}
        else
          {k, String.trim(v)}
        end
      else
        {k, v}
      end
    end)
  end

  @doc """
  Given params and a pair of fields,
  ensures the lower value of the two is assigned to the first
  field and the higher value to the second.

  %{f1: 5, f2: 3}
  |> min_and_max(~w(f1 f2))

  > %{f1: 3, f2: 5}
  """
  @spec min_and_max(map, [atom]) :: map
  def min_and_max(params, [field1, field2]) do
    field1 = Atom.to_string(field1)
    field2 = Atom.to_string(field2)

    value1 = params[field1] || ""
    value2 = params[field2] || ""

    mapped_values =
      cond do
        value1 == "" or value2 == "" -> %{}
        value1 > value2 -> %{field1 => value2, field2 => value1}
        true -> %{}
      end

    Map.merge(params, mapped_values)
  end

  @doc """
  Applied `Enum.uniq` to one or more fields in the params
  """
  @spec uniq_lists(map, list) :: map
  def uniq_lists(params, names) do
    names = Enum.map(names, fn n -> Atom.to_string(n) end)

    params
    |> Map.new(fn {k, v} ->
      case Enum.member?(names, k) do
        true ->
          case v do
            nil ->
              {k, nil}

            _ ->
              {k, Enum.uniq(v)}
          end

        false ->
          {k, v}
      end
    end)
  end

  @doc """
  Given a list of fields and a list of patterns, will apply Regex.replace for every
  pattern to each field.
  """
  @spec remove_characters(map, list, list) :: map
  def remove_characters(params, names, patterns) do
    names = Enum.map(names, fn n -> Atom.to_string(n) end)

    params
    |> Map.new(fn {k, v} ->
      case Enum.member?(names, k) do
        true ->
          case v do
            nil ->
              {k, nil}

            _ ->
              new_value =
                patterns
                |> Enum.reduce(v, fn pattern, acc ->
                  Regex.replace(pattern, acc, "")
                end)

              {
                k,
                new_value
              }
          end

        false ->
          {k, v}
      end
    end)
  end
end
