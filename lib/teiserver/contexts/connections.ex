defmodule Teiserver.Connections do
  @moduledoc """
  The context for all things connection related (mostly clients).
  """

  alias Teiserver.Account.User
  alias Teiserver.Connections.{Client, ClientLib}

  @doc section: :client
  @spec list_client_ids() :: [Teiserver.user_id()]
  defdelegate list_client_ids(), to: ClientLib

  @doc section: :client
  @spec get_client(Teiserver.user_id()) :: Client.t() | nil
  defdelegate get_client(user_id), to: ClientLib

  @doc section: :client
  @spec login_user(User.t()) :: Client.t()
  defdelegate login_user(user), to: ClientLib

  @doc section: :client
  @spec client_exists?(Teiserver.user_id()) :: pid() | boolean
  defdelegate client_exists?(user_id), to: ClientLib

  @doc false
  @spec get_client_pid(Teiserver.user_id()) :: pid() | nil
  defdelegate get_client_pid(user_id), to: ClientLib

  @doc false
  @spec cast_client(Teiserver.user_id(), any) :: any | nil
  defdelegate cast_client(user_id, msg), to: ClientLib

  @doc false
  @spec call_client(Teiserver.user_id(), any) :: any | nil
  defdelegate call_client(user_id, message), to: ClientLib

  @doc false
  @spec stop_client_server(Teiserver.user_id()) :: :ok | nil
  defdelegate stop_client_server(user_id), to: ClientLib
end
