defmodule Teiserver.Game.LobbyLib do
  @moduledoc """
  TODO: Library of lobby related functions.
  """
  alias Teiserver.Game.{Lobby, LobbySummary}
  alias Teiserver.Connections.ClientLib
  alias Teiserver.Connections

  @doc false
  @spec lobby_topic(Lobby.id()) :: String.t()
  def lobby_topic(lobby_id), do: "Teiserver.Game.Lobby:#{lobby_id}"

  @doc """
  Subscribes the process to lobby updates for this user
  """
  @spec subscribe_to_lobby(User.id() | User.t() | Client.t()) :: :ok
  def subscribe_to_lobby(lobby_or_lobby_id) do
    lobby_or_lobby_id
    |> lobby_topic()
    |> Teiserver.subscribe()
  end

  @doc """
  Unsubscribes the process to lobby updates for this user
  """
  @spec unsubscribe_from_lobby(User.id() | User.t() | Client.t()) :: :ok
  def unsubscribe_from_lobby(lobby_or_lobby_id) do
    lobby_or_lobby_id
    |> lobby_topic()
    |> Teiserver.unsubscribe()
  end

  @doc false
  @spec global_lobby_topic() :: String.t()
  def global_lobby_topic(), do: "Teiserver.Game.GlobalLobby"

  @doc """

  """
  @spec get_lobby(Lobby.id()) :: Lobby.t() | nil
  def get_lobby(id) when is_binary(id) do
    call_lobby(id, :get_lobby_state)
  end

  @doc """

  """
  @spec get_lobby_summary(Lobby.id()) :: LobbySummary.t() | nil
  def get_lobby_summary(id) when is_binary(id) do
    call_lobby(id, :get_lobby_summary)
  end

  @doc """

  """
  @spec get_lobby_attribute(Lobby.id(), atom()) :: any()
  def get_lobby_attribute(lobby_id, key) do
    call_lobby(lobby_id, {:get_lobby_attribute, key})
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
    Horde.Registry.select(Teiserver.LobbyRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  @doc """

  """
  @spec list_local_lobby_ids :: [Lobby.id()]
  def list_local_lobby_ids() do
    Registry.select(Teiserver.LocalLobbyRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  @doc """

  """
  @spec stream_lobby_summaries() :: Enumerable.t(LobbySummary.t())
  def stream_lobby_summaries() do
    list_lobby_ids()
    |> Stream.map(&get_lobby_summary/1)
    |> Stream.reject(&(&1 == nil))
  end

  @spec stream_lobby_summaries(map) :: Enumerable.t(LobbySummary.t())
  def stream_lobby_summaries(filters) do
    ids = filters["ids"] || list_lobby_ids()

    ids
    |> Stream.map(&get_lobby_summary/1)
    |> Stream.filter(fn l -> include_lobby?(l, filters) end)
  end

  @spec include_lobby?(LobbySummary.t(), map()) :: boolean
  defp include_lobby?(nil, _), do: false
  defp include_lobby?(lobby, filters) do
    [
      test_match_ongoing?(filters["match_ongoing?"], lobby),
      test_require_any_tags(filters["require_any_tags"], lobby),
      test_require_all_tags(filters["require_all_tags"], lobby),
      test_exclude_tags(filters["exclude_tags"], lobby),
      test_passworded?(filters["passworded?"], lobby),
      test_locked?(filters["locked?"], lobby),
      test_public?(filters["public?"], lobby),
      # test_match_type(filters["match_type"], lobby),
      test_rated?(filters["rated?"], lobby),
      test_game_version(filters["game_version"], lobby),
      test_game_name(filters["game_name"], lobby),
      test_min_player_count(filters["min_player_count"], lobby),
      test_max_player_count(filters["max_player_count"], lobby)
    ]
    |> Enum.all?
  end

  @spec test_match_ongoing?(nil | boolean, LobbySummary.t()) :: boolean
  defp test_match_ongoing?(nil, _), do: true
  defp test_match_ongoing?(value, lobby), do: lobby.match_ongoing? == value

  defp test_require_any_tags(nil, _), do: true
  defp test_require_any_tags(tags, lobby) do
    tags
    |> Enum.any?(fn tag ->
      Enum.member?(lobby.tags, tag)
    end)
  end

  defp test_require_all_tags(nil, _), do: true
  defp test_require_all_tags(tags, lobby) do
    tags
    |> Enum.all?(fn tag ->
      Enum.member?(lobby.tags, tag)
    end)
  end

  defp test_exclude_tags(nil, _), do: true
  defp test_exclude_tags(tags, lobby) do
    tags
    |> Enum.all?(fn tag ->
      not Enum.member?(lobby.tags, tag)
    end)
  end

  defp test_passworded?(nil, _), do: true
  defp test_passworded?(value, lobby), do: lobby.passworded? == value

  # defp test_match_type(nil, _), do: true
  # defp test_match_type(types, lobby) do
  #   Enum.member?(lobby.match_type, types)
  # end

  defp test_locked?(nil, _), do: true
  defp test_locked?(value, lobby), do: lobby.locked? == value

  defp test_public?(nil, _), do: true
  defp test_public?(value, lobby), do: lobby.public? == value

  defp test_rated?(nil, _), do: true
  defp test_rated?(value, lobby), do: lobby.rated? == value

  defp test_game_version(nil, _), do: true
  defp test_game_version(value, lobby), do: lobby.game_version == value

  defp test_game_name(nil, _), do: true
  defp test_game_name(value, lobby), do: lobby.game_name == value

  defp test_min_player_count(nil, _), do: true
  defp test_min_player_count(value, lobby), do: lobby.player_count >= value

  defp test_max_player_count(nil, _), do: true
  defp test_max_player_count(value, lobby), do: lobby.player_count <= value


  @doc """
  Given a user_id of the host and the initial lobby name, starts a process
  for tracking the lobby.

  It will then update the client of the host user and assign them to the lobby.

  ## Examples

      iex> open_lobby(123, "Name")
      {:ok, 456}

      iex> open_lobby(456, "Name")
      {:error, "Client is not connected"}
  """
  @spec open_lobby(Teiserver.user_id(), Lobby.name()) :: {:ok, Lobby.id()} | {:error, String.t()}
  def open_lobby(host_id, name) when is_binary(host_id) do
    client = Connections.get_client(host_id)

    cond do
      client == nil ->
        {:error, "Client is not connected"}

      client.connected? == false ->
        {:error, "Client is disconnected"}

      client.lobby_id != nil ->
        {:error, "Already in a lobby"}

      name == nil ->
        {:error, "No name supplied"}

      String.trim(name) == "" ->
        {:error, "No name supplied"}

      # All checks are good, lets try to create the lobby!
      true ->
        with {:ok, lobby} <- start_lobby_server(host_id, name),
             :ok <- cycle_lobby(lobby.id),
             _ <- ClientLib.update_client_full(host_id, %{lobby_id: lobby.id, lobby_host?: true}) do
          {:ok, lobby.id}
        else
          :failure1 -> :fail_result1
          :failure2 -> :fail_result2
          :failure3 -> :fail_result3
        end
    end
  end

  @doc """
  Used to cycle a lobby after a match has concluded.

  ## Examples

      iex> cycle_lobby(123)
      :ok

      iex> cycle_lobby(456)
      nil
  """
  @spec cycle_lobby(Lobby.id()) :: :ok
  def cycle_lobby(lobby_id) when is_binary(lobby_id) do
    host_id = get_lobby_attribute(lobby_id, :host_id)

    {:ok, match} =
      Teiserver.Game.create_match(%{
        public?: true,
        rated?: true,
        host_id: host_id,
        processed?: false,
        lobby_opened_at: Timex.now()
      })

    cast_lobby(lobby_id, {:cycle_lobby, match.id})
  end

  @doc """
  Used to tell a lobby process the current match has started

  ## Examples

      iex> lobby_start_match(123)
      :ok

      iex> lobby_start_match(456)
      nil
  """
  @spec lobby_start_match(Lobby.id()) :: :ok
  def lobby_start_match(lobby_id) when is_binary(lobby_id) do
    cast_lobby(lobby_id, :lobby_start_match)
  end

  @doc """
  Used to tell a lobby process the current match has started

  ## Examples

      iex> client_update_request(%{team_number: 1, id: 1}, 123)
      %{}

      iex> client_update_request(%{team_number: 1, id: 456}, 456)
      nil
  """
  @spec client_update_request(map(), Lobby.id()) :: map()
  def client_update_request(changes, lobby_id) when is_binary(lobby_id) do
    call_lobby(lobby_id, {:client_update_request, changes})
  end

  @doc """
  Given a lobby_id it will close the lobby. Every client in the lobby will be
  removed from the lobby.

  ## Examples

    iex> close_lobby(123)
    :ok
  """
  @spec close_lobby(Lobby.id()) :: :ok
  def close_lobby(lobby_id) when is_binary(lobby_id) do
    lobby = get_lobby(lobby_id)

    if lobby do
      lobby.members
      |> Enum.each(fn user_id ->
        ClientLib.update_client_full(user_id, %{lobby_id: nil, lobby_host?: false})
      end)

      ClientLib.update_client_full(lobby.host_id, %{lobby_id: nil, lobby_host?: false})
    end

    stop_lobby_server(lobby_id)
  end

  @doc """
  Adds a client to the lobby
  """
  @spec can_add_client_to_lobby?(Teiserver.user_id(), Lobby.id()) :: boolean()
  def can_add_client_to_lobby?(user_id, lobby_id) do
    call_lobby(lobby_id, {:can_add_client?, user_id})
  end

  @doc """
  Adds a client to the lobby
  """
  @spec add_client_to_lobby(Teiserver.user_id(), Lobby.id()) :: :ok | {:error, String.t()}
  def add_client_to_lobby(user_id, lobby_id) do
    call_lobby(lobby_id, {:add_client, user_id})
  end

  @doc """
  Adds a client to the lobby
  """
  @spec remove_client_from_lobby(Teiserver.user_id(), Lobby.id()) :: :ok | nil
  def remove_client_from_lobby(user_id, lobby_id) do
    cast_lobby(lobby_id, {:remove_client, user_id})
  end

  @doc false
  @spec start_lobby_server(Teiserver.user_id(), Lobby.name()) :: {:ok, Lobby.t()}
  def start_lobby_server(host_id, name) do
    lobby = Lobby.new(host_id, name)

    {:ok, _pid} =
      lobby
      |> do_start_lobby_server()

    {:ok, lobby}
  end

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
    case Horde.Registry.lookup(Teiserver.LobbyRegistry, lobby_id) do
      [{_pid, _}] -> true
      _ -> false
    end
  end

  @doc false
  @spec get_lobby_pid(Lobby.id()) :: pid() | nil
  def get_lobby_pid(lobby_id) do
    case Horde.Registry.lookup(Teiserver.LobbyRegistry, lobby_id) do
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
  def call_lobby(lobby_id, message) when is_binary(lobby_id) do
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

  @doc """
  Tests is the lobby name is acceptable. Can be over-ridden using the config [fn_lobby_name_acceptor](config.html#fn_lobby_name_acceptor)
  """
  @spec lobby_name_acceptable?(String.t()) :: boolean
  def lobby_name_acceptable?(name) do
    if Application.get_env(:teiserver, :fn_lobby_name_acceptor) do
      f = Application.get_env(:teiserver, :fn_lobby_name_acceptor)
      f.(name)
    else
      default_lobby_name_acceptable?(name)
    end
  end

  @spec default_lobby_name_acceptable?(String.t()) :: boolean
  def default_lobby_name_acceptable?(_name) do
    true
  end
end
