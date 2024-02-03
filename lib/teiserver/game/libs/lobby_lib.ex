defmodule Teiserver.Game.LobbyLib do
  @moduledoc """

  """

  @doc false
  @spec lobby_topic(Teiserver.lobby_id()) :: String.t()
  def lobby_topic(lobby_id), do: "Teiserver.Game.Lobby:#{lobby_id}"
end
