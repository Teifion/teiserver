defmodule Teiserver.Connections do
  @moduledoc """
  The context for all things connection related, mostly `Teiserver.Connections.Client`

  # Clients
  Clients are represented by a process holding their state, this process controls all updates to their state.

  ## Creating a client
  Clients are created using `connect_user/1`, this will create (if it doesn't already exist) a client process. Any process connecting a user will be subscribed to the `Teiserver.ClientUpdates:{user_id}` channel.

  ## Destroying clients
  TODO: Implement and document
  """

  alias Teiserver.Account.User
  alias Teiserver.Connections.{Client, ClientLib}

  @doc false
  @spec client_topic(Teiserver.user_id() | User.t() | Client.t()) :: String.t()
  defdelegate client_topic(client_or_user_or_user_id), to: ClientLib

  @doc section: :client
  @spec list_client_ids() :: [Teiserver.user_id()]
  defdelegate list_client_ids(), to: ClientLib

  @doc section: :client
  @spec get_client(Teiserver.user_id()) :: Client.t() | nil
  defdelegate get_client(user_id), to: ClientLib

  @doc section: :client
  @spec update_client(Teiserver.user_id(), map) :: Client.t() | nil
  defdelegate update_client(user_id, updates), to: ClientLib

  @doc section: :client
  @spec connect_user(Teiserver.user_id()) :: Client.t()
  defdelegate connect_user(user_id), to: ClientLib

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
