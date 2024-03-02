defmodule Teiserver.Communication.MatchMessageLib do
  @moduledoc """
  Library of match_message related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Communication.{MatchMessage, MatchMessageQueries}
  alias Teiserver.Game.Match

  @doc false
  @spec match_messaging_topic(Teiserver.match_id() | Match.t()) :: String.t()
  def match_messaging_topic(%Match{id: match_id}), do: "Teiserver.Communication.Match.#{match_id}"
  def match_messaging_topic(match_id), do: "Teiserver.Communication.Match.#{match_id}"

  @doc """
  Joins your process to match messages
  """
  @spec subscribe_to_match_messages(Match.id() | Match.t()) :: :ok
  def subscribe_to_match_messages(match_or_match_id) do
    match_or_match_id
    |> match_messaging_topic()
    |> Teiserver.subscribe()
  end

  @doc """
  Removes your process from a match's messages
  """
  @spec unsubscribe_from_match_messages(Match.id() | Match.t()) :: :ok
  def unsubscribe_from_match_messages(match_or_match_id) do
    match_or_match_id
    |> match_messaging_topic()
    |> Teiserver.unsubscribe()
  end

  @doc """
  Returns a list of messages from a match ordered as the newest first.

  In the event of there being ne messages for a match of that ID the function will return an empty list.

  ## Examples

      iex> list_recent_match_messages(123)
      [%MatchMessage{}, ...]

      iex> list_recent_match_messages(456)
      []
  """
  @spec list_recent_match_messages(Match.id(), non_neg_integer()) :: [MatchMessage.t()]
  def list_recent_match_messages(match_id, limit \\ 50) when is_binary(match_id) do
    list_match_messages(where: [match_id: match_id], limit: limit, order_by: ["Newest first"])
  end

  @doc """
    - Creates a match message
    - If successful generate a pubsub message

    ## Examples

        iex> send_match_message(123, 123, "Message content")
        {:ok, %MatchMessage{}}

        iex> send_match_message(456, 456, "Message content")
        {:error, %Ecto.Changeset{}}
  """
  @spec send_match_message(Teiserver.user_id(), Match.id(), String.t()) ::
          {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  @spec send_match_message(Teiserver.user_id(), Match.id(), String.t(), map()) ::
          {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  def send_match_message(sender_id, match_id, content, attrs \\ %{}) do
    attrs =
      Map.merge(
        %{
          sender_id: sender_id,
          match_id: match_id,
          content: content,
          inserted_at: Timex.now()
        },
        attrs
      )

    case create_match_message(attrs) do
      {:ok, match_message} ->
        topic = match_messaging_topic(match_message.match_id)

        Teiserver.broadcast(
          topic,
          %{
            event: :message_received,
            match_message: match_message
          }
        )

        {:ok, match_message}

      err ->
        err
    end
  end

  @doc """
  Returns the list of match_messages.

  ## Examples

      iex> list_match_messages()
      [%MatchMessage{}, ...]

  """
  @spec list_match_messages(list) :: list
  def list_match_messages(query_args \\ []) do
    query_args
    |> MatchMessageQueries.match_message_query()
    |> Repo.all()
  end

  @doc """
  Gets a single match_message.

  Raises `Ecto.NoResultsError` if the MatchMessage does not exist.

  ## Examples

      iex> get_match_message!(123)
      %MatchMessage{}

      iex> get_match_message!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_match_message!(MatchMessage.id()) :: MatchMessage.t()
  @spec get_match_message!(MatchMessage.id(), Teiserver.query_args()) :: MatchMessage.t()
  def get_match_message!(match_message_id, query_args \\ []) do
    (query_args ++ [id: match_message_id])
    |> MatchMessageQueries.match_message_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single match_message.

  Returns nil if the MatchMessage does not exist.

  ## Examples

      iex> get_match_message(123)
      %MatchMessage{}

      iex> get_match_message(456)
      nil

  """
  @spec get_match_message(MatchMessage.id()) :: MatchMessage.t() | nil
  @spec get_match_message(MatchMessage.id(), Teiserver.query_args()) :: MatchMessage.t() | nil
  def get_match_message(match_message_id, query_args \\ []) do
    (query_args ++ [id: match_message_id])
    |> MatchMessageQueries.match_message_query()
    |> Repo.one()
  end

  @doc """
  Creates a match_message.

  ## Examples

      iex> create_match_message(%{field: value})
      {:ok, %MatchMessage{}}

      iex> create_match_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_match_message(map) :: {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  def create_match_message(attrs \\ %{}) do
    %MatchMessage{}
    |> MatchMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match_message.

  ## Examples

      iex> update_match_message(match_message, %{field: new_value})
      {:ok, %MatchMessage{}}

      iex> update_match_message(match_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_match_message(MatchMessage.t(), map) ::
          {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  def update_match_message(%MatchMessage{} = match_message, attrs) do
    match_message
    |> MatchMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match_message.

  ## Examples

      iex> delete_match_message(match_message)
      {:ok, %MatchMessage{}}

      iex> delete_match_message(match_message)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_match_message(MatchMessage.t()) ::
          {:ok, MatchMessage.t()} | {:error, Ecto.Changeset.t()}
  def delete_match_message(%MatchMessage{} = match_message) do
    Repo.delete(match_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match_message changes.

  ## Examples

      iex> change_match_message(match_message)
      %Ecto.Changeset{data: %MatchMessage{}}

  """
  @spec change_match_message(MatchMessage.t(), map) :: Ecto.Changeset.t()
  def change_match_message(%MatchMessage{} = match_message, attrs \\ %{}) do
    MatchMessage.changeset(match_message, attrs)
  end
end
