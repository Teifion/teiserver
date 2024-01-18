defmodule Teiserver.Communication.DirectMessageLib do
  @moduledoc """
  Library of direct_message related functions.
  """
  use TeiserverMacros, :library
  alias Teiserver.Communication.{DirectMessage, DirectMessageQueries}


  @doc """
  - Creates a direct message
  - If successful generate a pubsub message

  ## Examples

      iex> send_direct_message(123, 124, "Message content")
      {:ok, %DirectMessage{}}

      iex> send_direct_message(456, 457, "Message content")
      {:error, %Ecto.Changeset{}}
  """
  @spec send_direct_message(Teiserver.user_id(), Room.id(), String.t(), map()) :: {:ok, RoomMessage.t()} | {:error, Ecto.Changeset}
  def send_direct_message(from_id, to_id, content, attrs \\ %{}) do
    attrs = Map.merge(%{
      from_id: from_id,
      to_id: to_id,
      content: content,
      inserted_at: Timex.now()
    }, attrs)

    case create_direct_message(attrs) do
      {:ok, direct_message} ->
        Teiserver.broadcast(
          "Teiserver.Communication:User.#{direct_message.from_id}",
          %{
            event: :message_sent,
            direct_message: direct_message
          }
        )

        Teiserver.broadcast(
          "Teiserver.Communication:User.#{direct_message.to_id}",
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
  @spec list_direct_messages(list) :: list
  def list_direct_messages(query_args \\ []) do
    query_args
    |> DirectMessageQueries.direct_message_query()
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
  @spec get_direct_message!(non_neg_integer()) :: DirectMessage.t()
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
  @spec get_direct_message(non_neg_integer(), list) :: DirectMessage.t() | nil
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
