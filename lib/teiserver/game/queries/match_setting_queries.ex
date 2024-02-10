defmodule Teiserver.Game.MatchSettingQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Game.MatchSetting
  require Logger

  @spec match_setting_query(Teiserver.query_args()) :: Ecto.Query.t()
  def match_setting_query(args) do
    query = from(match_settings in MatchSetting)

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

  @spec _where(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :match_id, match_ids) when is_list(match_ids) do
    from(match_settingss in query,
      where: match_settingss.match_id in ^match_ids
    )
  end

  def _where(query, :match_id, match_id) do
    from(match_settingss in query,
      where: match_settingss.match_id == ^match_id
    )
  end

  def _where(query, :type_id, type_ids) when is_list(type_ids) do
    from(match_settingss in query,
      where: match_settingss.type_id in ^type_ids
    )
  end

  def _where(query, :type_id, type_id) do
    from(match_settingss in query,
      where: match_settingss.type_id == ^type_id
    )
  end

  def _where(query, :value, values) when is_list(values) do
    from(match_settingss in query,
      where: match_settingss.value in ^values
    )
  end

  def _where(query, :value, value) do
    from(match_settingss in query,
      where: match_settingss.value == ^value
    )
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) when is_list(params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Value (A-Z)") do
    from(match_settings in query,
      order_by: [asc: match_settings.value]
    )
  end

  def _order_by(query, "Value (Z-A)") do
    from(match_settings in query,
      order_by: [desc: match_settings.value]
    )
  end

  @spec do_preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  @spec _preload(Ecto.Query.t(), any) :: Ecto.Query.t()
  def _preload(query, :type) do
    from match_settings in query,
      left_join: types in assoc(match_settings, :type),
      preload: [type: types]
  end

  def _preload(query, :match) do
    from match_settings in query,
      left_join: matches in assoc(match_settings, :match),
      preload: [match: matches]
  end
end
