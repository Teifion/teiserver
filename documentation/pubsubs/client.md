# Client messages
PubSub messages sent out in relation to changes to clients.

## `Teiserver.Connections.Client:{user_id}`
The pubsub messages received by anybody watching this account.

### Updated client - `:client_updated`
Sent whenever the client in question is updated.

- `:reason` - The reason for the change
- `:client` - A `Teiserver.Connections.Client` of the new client values

```elixir
%{
  event: :client_updated,
  update_id: integer(),
  client: Client.t()
}
```

### Joined lobby - `:joined_lobby`
Sent whenever the client is added to a lobby; if you are subscribed to this topic you should also received a `client_updated` message. This separate message is to make matching on changing state easier.

- `:lobby_id` - The ID of the lobby joined
- `:user_id` - The ID of the user (which should also be present in the topic)

```elixir
%{
  event: :joined_lobby,
  lobby_id: Lobby.id(),
  user_id: User.id()
}
```

### Left lobby - `:left_lobby`
Sent whenever the client leaves a lobby; if you are subscribed to this topic you should also received a `client_updated` message. This separate message is to make matching on changing state easier.

- `:lobby_id` - The ID of the lobby left
- `:user_id` - The ID of the user (which should also be present in the topic)

```elixir
%{
  event: :left_lobby,
  lobby_id: Lobby.id(),
  user_id: User.id()
}
```

### Disconnected client - `:client_disconnected`
Sent when the client has no more connections

- `:client` - A `Teiserver.Connections.Client` of the new client values

```elixir
%{
  event: :client_disconnected,
  client: Client.t()
}
```

### Destroyed client - `:client_destroyed`
Sent when the client server process is destroyed.

- `:user_id` - `Teiserver.Connections.User.id()` of the new client values

```elixir
%{
  event: :client_destroyed,
  user_id: User.id()
}
```
