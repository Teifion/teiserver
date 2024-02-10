defmodule Teiserver.CommunicationFixtures do
  @moduledoc false
  import Teiserver.AccountFixtures, only: [user_fixture: 0]
  import Teiserver.GameFixtures, only: [incomplete_match_fixture: 0]
  alias Teiserver.Communication.{Room, RoomMessage, DirectMessage, MatchMessage}

  @spec room_fixture() :: Room.t()
  @spec room_fixture(map) :: Room.t()
  def room_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    Room.changeset(
      %Room{},
      %{
        name: data[:name] || "room_name_#{r}"
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec room_message_fixture() :: RoomMessage.t()
  @spec room_message_fixture(map) :: RoomMessage.t()
  def room_message_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    RoomMessage.changeset(
      %RoomMessage{},
      %{
        content: data[:content] || "room_message_content_#{r}",
        inserted_at: data[:inserted_at] || Timex.now(),
        sender_id: data[:sender_id] || user_fixture().id,
        room_id: data[:room_id] || room_fixture().id
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec direct_message_fixture() :: DirectMessage.t()
  @spec direct_message_fixture(map) :: DirectMessage.t()
  def direct_message_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    DirectMessage.changeset(
      %DirectMessage{},
      %{
        content: data[:content] || "room_message_content_#{r}",
        inserted_at: data[:inserted_at] || Timex.now(),
        delivered?: data[:delivered?] || false,
        read?: data[:read?] || false,
        from_id: data[:from_id] || user_fixture().id,
        to_id: data[:to_id] || user_fixture().id
      }
    )
    |> Teiserver.Repo.insert!()
  end

  @spec match_message_fixture() :: MatchMessage.t()
  @spec match_message_fixture(map) :: MatchMessage.t()
  def match_message_fixture(data \\ %{}) do
    r = :rand.uniform(999_999_999)

    MatchMessage.changeset(
      %MatchMessage{},
      %{
        content: data[:content] || "match_message_content_#{r}",
        inserted_at: data[:inserted_at] || Timex.now(),
        sender_id: data[:sender_id] || user_fixture().id,
        match_id: data[:match_id] || incomplete_match_fixture().id
      }
    )
    |> Teiserver.Repo.insert!()
  end
end
