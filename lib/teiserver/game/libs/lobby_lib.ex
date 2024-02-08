defmodule Teiserver.Game.LobbyLib do
  @moduledoc """

  """
  alias Teiserver.Game.{Lobby, LobbySummary}

  @doc false
  @spec lobby_topic(Lobby.id()) :: String.t()
  def lobby_topic(lobby_id), do: "Teiserver.Game.Lobby:#{lobby_id}"

  @doc false
  @spec global_lobby_topic() :: String.t()
  def global_lobby_topic(), do: "Teiserver.Game.GlobalLobby"

  @doc """

  """
  @spec get_lobby(Lobby.id()) :: Lobby.t() | nil
  def get_lobby(id) when is_integer(id) do
    call_lobby(id, :get_lobby_state)
  end

  @doc """

  """
  @spec get_lobby_summary(Lobby.id()) :: LobbySummary.t() | nil
  def get_lobby_summary(id) when is_integer(id) do
    call_lobby(id, :get_lobby_summary)
  end

  @doc """

  """
  @spec get_lobby_attribute(Lobby.id(), atom()) :: any()
  def get_lobby_attribute(lobby_id, key) do
    call_lobby(lobby_id, {:get_attribute, key})
  end

  @doc """

  """
  @spec update_lobby(Lobby.id(), map) :: :ok | nil
  def update_lobby(lobby_id, data) do
    cast_lobby(lobby_id, {:update_lobby, data})
  end

  @doc """

  """
  @spec list_lobby_ids :: [Lobby.id()]
  def list_lobby_ids() do
    Registry.select(Teiserver.LobbyRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  @doc """

  """
  @spec list_lobbies() :: [Lobby.t()]
  def list_lobbies() do
    list_lobby_ids()
    |> Enum.map(&get_lobby/1)
    |> Enum.reject(&(&1 == nil))
  end

  @spec start_lobby_server(Teiserver.user_id(), Lobby.name()) :: {:ok, Lobby.id()}
  def start_lobby_server(host_id, name) do
    id = Teiserver.LobbyIdServer.get_next_lobby_id()

    {:ok, _pid} =
      id
      |> Lobby.new(host_id, name)
      |> do_start_lobby_server()

    {:ok, id}
  end

  @spec set_next_lobby_id(Lobby.id()) :: :ok | {:error, :no_pid}
  defdelegate set_next_lobby_id(next_id), to: Teiserver.LobbyIdServer

  # Process stuff
  @doc false
  @spec do_start_lobby_server(Lobby.t()) :: {:ok, pid()}
  defp do_start_lobby_server(%Lobby{} = lobby) do
    DynamicSupervisor.start_child(Teiserver.LobbySupervisor, {
      Teiserver.Game.LobbyServer,
      name: "lobby_#{lobby.id}",
      data: %{
        lobby: lobby
      }
    })
  end

  @doc false
  @spec lobby_exists?(Lobby.id()) :: pid() | boolean
  def lobby_exists?(lobby_id) do
    case Registry.lookup(Teiserver.LobbyRegistry, lobby_id) do
      [{_pid, _}] -> true
      _ -> false
    end
  end

  @doc false
  @spec get_lobby_pid(Lobby.id()) :: pid() | nil
  def get_lobby_pid(lobby_id) do
    case Registry.lookup(Teiserver.LobbyRegistry, lobby_id) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end

  @doc false
  @spec cast_lobby(Lobby.id(), any) :: any | nil
  def cast_lobby(lobby_id, msg) do
    case get_lobby_pid(lobby_id) do
      nil ->
        nil

      pid ->
        GenServer.cast(pid, msg)
        :ok
    end
  end

  @doc false
  @spec call_lobby(Lobby.id(), any) :: any | nil
  def call_lobby(lobby_id, message) when is_integer(lobby_id) do
    case get_lobby_pid(lobby_id) do
      nil ->
        nil

      pid ->
        try do
          GenServer.call(pid, message)

          # If the process has somehow died, we just return nil
        catch
          :exit, _ ->
            nil
        end
    end
  end

  @doc false
  @spec stop_lobby_server(Lobby.id()) :: :ok | nil
  def stop_lobby_server(lobby_id) do
    case get_lobby_pid(lobby_id) do
      nil ->
        nil

      p ->
        Teiserver.broadcast(lobby_topic(lobby_id), %{
          event: :lobby_closed,
          lobby_id: lobby_id
        })

        Teiserver.broadcast(global_lobby_topic(), %{
          event: :lobby_closed,
          lobby_id: lobby_id
        })

        DynamicSupervisor.terminate_child(Teiserver.LobbySupervisor, p)
        :ok
    end
  end
end
