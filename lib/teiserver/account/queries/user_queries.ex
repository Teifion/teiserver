defmodule Teiserver.Account.UserQueries do
  @moduledoc false
  use TeiserverMacros, :queries
  alias Teiserver.Account.User
  require Logger

  @spec user_query(Teiserver.query_args()) :: Ecto.Query.t()
  def user_query(args) do
    query = from(users in User)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
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

  @spec _where(Ecto.Query.t(), atom, any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id_list) when is_list(id_list) do
    from(users in query,
      where: users.id in ^id_list
    )
  end

  def _where(query, :id, id) do
    from(users in query,
      where: users.id == ^id
    )
  end

  def _where(query, :name, name) do
    from(users in query,
      where: users.name == ^name
    )
  end

  def _where(query, :name_lower, value) do
    from(users in query,
      where: lower(users.name) == ^String.downcase(value)
    )
  end

  def _where(query, :email, email) do
    from(users in query,
      where: users.email == ^email
    )
  end

  def _where(query, :email_lower, value) do
    from(users in query,
      where: lower(users.email) == ^String.downcase(value)
    )
  end

  def _where(query, :name_or_email, value) do
    from(users in query,
      where: users.email == ^value or users.name == ^value
    )
  end

  def _where(query, :name_like, name) do
    uname = "%" <> name <> "%"

    from(users in query,
      where: ilike(users.name, ^uname)
    )
  end

  def _where(query, :basic_search, value) do
    from(users in query,
      where:
        ilike(users.name, ^"%#{value}%") or
          ilike(users.email, ^"%#{value}%")
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(users in query,
      where: users.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(users in query,
      where: users.inserted_at < ^timestamp
    )
  end

  def _where(query, :has_group, group_name) do
    from(users in query,
      where: ^group_name in users.groups
    )
  end

  def _where(query, :not_has_group, group_name) do
    from(users in query,
      where: ^group_name not in users.groups
    )
  end

  def _where(query, :has_permission, permission_name) do
    from(users in query,
      where: ^permission_name in users.permissions
    )
  end

  def _where(query, :not_has_permission, permission_name) do
    from(users in query,
      where: ^permission_name not in users.permissions
    )
  end

  def _where(query, :has_restriction, restriction_name) do
    from(users in query,
      where: ^restriction_name in users.restrictions
    )
  end

  def _where(query, :not_has_restriction, restriction_name) do
    from(users in query,
      where: ^restriction_name not in users.restrictions
    )
  end

  def _where(query, :smurf_of, "Smurf"), do: _where(query, :smurf_of, true)
  def _where(query, :smurf_of, "Non-smurf"), do: _where(query, :smurf_of, false)
  def _where(query, :smurf_of, userid) when is_binary(userid) do
    from(users in query,
      where: users.smurf_of_id == ^userid
    )
  end

  def _where(query, :smurf_of, true) do
    from(users in query,
      where: not is_nil(users.smurf_of_id)
    )
  end

  def _where(query, :smurf_of, false) do
    from(users in query,
      where: is_nil(users.smurf_of_id)
    )
  end

  def _where(query, :behaviour_score_gt, score) do
    from(users in query,
      where: users.behaviour_score > ^score
    )
  end

  def _where(query, :behaviour_score_lt, score) do
    from(users in query,
      where: users.behaviour_score < ^score
    )
  end

  def _where(query, :last_played_after, timestamp) do
    from(users in query,
      where: users.last_played_at >= ^timestamp
    )
  end

  def _where(query, :last_played_before, timestamp) do
    from(users in query,
      where: users.last_played_at < ^timestamp
    )
  end

  def _where(query, :last_login_after, timestamp) do
    from(users in query,
      where: users.last_login_at >= ^timestamp
    )
  end

  def _where(query, :last_login_before, timestamp) do
    from(users in query,
      where: users.last_login_at < ^timestamp
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
  def _order_by(query, "Name (A-Z)") do
    from(users in query,
      order_by: [asc: users.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(users in query,
      order_by: [desc: users.name]
    )
  end

  def _order_by(query, "Newest first") do
    from(users in query,
      order_by: [desc: users.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(users in query,
      order_by: [asc: users.inserted_at]
    )
  end

  def _order_by(query, "Last logged in") do
    from(users in query,
      order_by: [asc: users.last_login_at]
    )
  end

  def _order_by(query, "Last played") do
    from(users in query,
      order_by: [desc: users.last_played_at]
    )
  end

  def _order_by(query, "Last logged out") do
    from(users in query,
      order_by: [desc: users.last_logout_at]
    )
  end

  @spec do_preload(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  def _preload(query, :extra_data) do
    from(user in query,
      left_join: extra_datas in assoc(user, :extra_data),
      preload: [extra_data: extra_datas]
    )
  end
end
