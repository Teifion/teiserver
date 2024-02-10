# Communication messages
Messages related to communication between players including RoomMessages, DirectMessages and LobbyMessages.

## `Teiserver.Communication.Room:{room_id}`
Pubsub messages related to the Room.

### Message received
Sent whenever a new message is sent into a room

- `:message` - A `Teiserver.Communication.RoomMessage` representing the message received

```elixir
%{
  event: :message_received,
  message: RoomMessage.t()
}
```

## `Teiserver.Communication.User:{user_id}`
Messages related to the user and not a wider context.

### Message received
Sent whenever a new DirectMessage is sent to this user.

- `:message` - A `Teiserver.Communication.DirectMessage` representing the message received

```elixir
%{
  event: :message_received,
  message: DirectMessage.t()
}
```

### Message sent
Sent whenever a new DirectMessage is sent by this user.

- `:message` - A `Teiserver.Communication.DirectMessage` representing the message sent

```elixir
%{
  event: :message_sent,
  message: DirectMessage.t()
}
```

## `Teiserver.Communication.Match:{match_id}`
Pubsub messages related to the Match.

### Message received
Sent whenever a new message is sent into a match

- `:message` - A `Teiserver.Communication.MatchMessage` representing the message received

```elixir
%{
  event: :message_received,
  message: MatchMessage.t()
}
```