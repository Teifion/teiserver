defmodule Teiserver.Communication.DirectMessageLib do
  @moduledoc """
  Library of direct_message related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Account.User
  alias Teiserver.Communication.{DirectMessage, DirectMessageQueries}

  @doc false
  @spec user_messaging_topic(Teiserver.user_id() | User.t()) :: String.t()
  def user_messaging_topic(%User{id: user_id}), do: "Teiserver.Communication.User:#{user_id}"
  def user_messaging_topic(user_id), do: "Teiserver.Communication.User:#{user_id}"

  @doc """
  Joins your process to match messages
  """
  @spec subscribe_to_user_messaging(User.id() | User.t()) :: :ok
  def subscribe_to_user_messaging(user_or_user_id) do
    user_or_user_id
    |> user_messaging_topic()
    |> Teiserver.subscribe()
  end

  @doc """
  Removes your process from a match's messages
  """
  @spec unsubscribe_from_user_messaging(User.id() | User.t()) :: :ok
  def unsubscribe_from_user_messaging(user_or_user_id) do
    user_or_user_id
    |> user_messaging_topic()
    |> Teiserver.unsubscribe()
  end

  @doc """
  - Creates a direct message
  - If successful generate a pubsub message

  ## Examples

      iex> send_direct_message(123, 124, "Message content")
      {:ok, %DirectMessage{}}

      iex> send_direct_message(456, 457, "Message content")
      {:error, %Ecto.Changeset{}}
  """
  @spec send_direct_message(Teiserver.user_id(), Room.id(), String.t(), map()) ::
          {:ok, RoomMessage.t()} | {:error, Ecto.Changeset.t()}
  def send_direct_message(from_id, to_id, content, attrs \\ %{}) do
    attrs =
      Map.merge(
        %{
          from_id: from_id,
          to_id: to_id,
          content: content,
          inserted_at: Timex.now()
        },
        attrs
      )

    case create_direct_message(attrs) do
      {:ok, direct_message} ->
        Teiserver.broadcast(
          user_messaging_topic(direct_message.from_id),
          %{
            event: :message_sent,
            direct_message: direct_message
          }
        )

        Teiserver.broadcast(
          user_messaging_topic(direct_message.to_id),
          %{
            event: :message_received,
            direct_message: direct_message
          }
        )

        {:ok, direct_message}

      err ->
        err
    end
  end

  @doc """
  Returns the list of direct_messages.

  ## Examples

      iex> list_direct_messages()
      [%DirectMessage{}, ...]

  """
  @spec list_direct_messages(Teiserver.query_args()) :: [DirectMessage.t()]
  def list_direct_messages(query_args \\ []) do
    query_args
    |> DirectMessageQueries.direct_message_query()
    |> Repo.all()
  end

  @doc """
  Returns the list of direct_messages for a specific user (to and from).

  ## Examples

      iex> list_direct_messages_for_user(user_id)
      [%DirectMessage{}, ...]

  """
  @spec list_direct_messages_for_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_for_user(Teiserver.user_id(), Teiserver.query_args()) :: [
          DirectMessage.t()
        ]
  def list_direct_messages_for_user(user_id, query_args \\ []) do
    query_args
    |> DirectMessageQueries.direct_message_query()
    |> DirectMessageQueries.do_where(to_or_from_id: user_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of direct_messages sent to a specific user.

  ## Examples

      iex> list_direct_messages_to_user(user_id)
      [%DirectMessage{}, ...]

  """
  @spec list_direct_messages_to_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_to_user(Teiserver.user_id(), Teiserver.query_args()) :: [
          DirectMessage.t()
        ]
  def list_direct_messages_to_user(user_id, query_args \\ []) do
    query_args
    |> DirectMessageQueries.direct_message_query()
    |> DirectMessageQueries.do_where(to_id: user_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of direct_messages sent from a specific user.

  ## Examples

      iex> list_direct_messages_from_user(user_id)
      [%DirectMessage{}, ...]

  """
  @spec list_direct_messages_from_user(Teiserver.user_id()) :: [DirectMessage.t()]
  @spec list_direct_messages_from_user(Teiserver.user_id(), Teiserver.query_args()) :: [
          DirectMessage.t()
        ]
  def list_direct_messages_from_user(user_id, query_args \\ []) do
    query_args
    |> DirectMessageQueries.direct_message_query()
    |> DirectMessageQueries.do_where(from_id: user_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of direct_messages sent from a specific user to a specific user.

  ## Examples

      iex> list_direct_messages_from_user_to_user(from_id, to_id)
      [%DirectMessage{}, ...]

  """
  @spec list_direct_messages_from_user_to_user(
          Teiserver.user_id(),
          Teiserver.user_id(),
          Teiserver.query_args()
        ) ::
          [DirectMessage.t()]
  def list_direct_messages_from_user_to_user(from_id, to_id, query_args \\ []) do
    query_args
    |> DirectMessageQueries.direct_message_query()
    |> DirectMessageQueries.do_where(
      from_id: from_id,
      to_id: to_id
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of direct_messages sent between specific users.

  ## Examples

      iex> list_direct_messages_between_users(user1_id, user2_id)
      [%DirectMessage{}, ...]

      iex> list_direct_messages_between_users(user1_id, user2_id, limit: 10, order_by: ["Newest first"])
      [%DirectMessage{}, ...]

  """
  @spec list_direct_messages_between_users(Teiserver.user_id(), Teiserver.user_id()) :: [
          DirectMessage.t()
        ]
  @spec list_direct_messages_between_users(
          Teiserver.user_id(),
          Teiserver.user_id(),
          Teiserver.query_args()
        ) :: [DirectMessage.t()]
  def list_direct_messages_between_users(user_id1, user_id2, query_args \\ []) do
    query_args
    |> DirectMessageQueries.direct_message_query()
    |> DirectMessageQueries.do_where(
      from_id: [user_id1, user_id2],
      to_id: [user_id1, user_id2]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single direct_message.

  Raises `Ecto.NoResultsError` if the DirectMessage does not exist.

  ## Examples

      iex> get_direct_message!(123)
      %DirectMessage{}

      iex> get_direct_message!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_direct_message!(DirectMessage.id()) :: DirectMessage.t()
  @spec get_direct_message!(DirectMessage.id(), Teiserver.query_args()) :: DirectMessage.t()
  def get_direct_message!(direct_message_id, query_args \\ []) do
    (query_args ++ [id: direct_message_id])
    |> DirectMessageQueries.direct_message_query()
    |> Repo.one!()
  end

  @doc """
  Gets a single direct_message.

  Returns nil if the DirectMessage does not exist.

  ## Examples

      iex> get_direct_message(123)
      %DirectMessage{}

      iex> get_direct_message(456)
      nil

  """
  @spec get_direct_message(DirectMessage.id()) :: DirectMessage.t() | nil
  @spec get_direct_message(DirectMessage.id(), Teiserver.query_args()) :: DirectMessage.t() | nil
  def get_direct_message(direct_message_id, query_args \\ []) do
    (query_args ++ [id: direct_message_id])
    |> DirectMessageQueries.direct_message_query()
    |> Repo.one()
  end

  @doc """
  Creates a direct_message.

  ## Examples

      iex> create_direct_message(%{field: value})
      {:ok, %DirectMessage{}}

      iex> create_direct_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_direct_message(map) :: {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  def create_direct_message(attrs \\ %{}) do
    %DirectMessage{}
    |> DirectMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a direct_message.

  ## Examples

      iex> update_direct_message(direct_message, %{field: new_value})
      {:ok, %DirectMessage{}}

      iex> update_direct_message(direct_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_direct_message(DirectMessage.t(), map) ::
          {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  def update_direct_message(%DirectMessage{} = direct_message, attrs) do
    direct_message
    |> DirectMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a direct_message.

  ## Examples

      iex> delete_direct_message(direct_message)
      {:ok, %DirectMessage{}}

      iex> delete_direct_message(direct_message)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_direct_message(DirectMessage.t()) ::
          {:ok, DirectMessage.t()} | {:error, Ecto.Changeset.t()}
  def delete_direct_message(%DirectMessage{} = direct_message) do
    Repo.delete(direct_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking direct_message changes.

  ## Examples

      iex> change_direct_message(direct_message)
      %Ecto.Changeset{data: %DirectMessage{}}

  """
  @spec change_direct_message(DirectMessage.t(), map) :: Ecto.Changeset.t()
  def change_direct_message(%DirectMessage{} = direct_message, attrs \\ %{}) do
    DirectMessage.changeset(direct_message, attrs)
  end
end
