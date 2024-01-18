defmodule Teiserver.Helpers.PubSubHelper do
  @moduledoc false
  alias Phoenix.PubSub

  @doc false
  @spec broadcast(String.t(), map()) :: :ok
  def broadcast(topic, %{event: _} = message) do
    PubSub.broadcast(
      Teiserver.PubSub,
      topic,
      Map.put(message, :topic, topic)
    )
  end
end
