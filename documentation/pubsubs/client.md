# Client messages
PubSub messages sent out in relation to changes to clients.

## `Teiserver.Connections.Client:{user_id}`
The pubsub messages received by anybody watching this account.

### Updated client - `:client_updated`
Sent whenever the client in question is updated.

- `:update_id` - An incremental number to allow for out of order messages
- `:client` - A `Teiserver.Connections.Client` of the new client values

```elixir
%{
  event: :client_updated,
  update_id: integer(),
  client: Client.t()
}
```

### Connected client - `:client_connected`
Sent when the client goes from 0 to 1 connections. Will not re-send unless the client server first disconnects again.

- `:client` - A `Teiserver.Connections.Client` of the new client values

```elixir
%{
  event: :client_connected,
  client: Client.t()
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
