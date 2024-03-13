# Lobby messages
PubSub messages sent out in relation to changes to lobbies.

## `Teiserver.Game.GlobalLobby`
Messages for everybody for discoverability of lobbies.

### Open - `:lobby_opened`

### Closed - `:lobby_closed`
- `:lobby_id` - The id of the lobby closed

```elixir
%{
  event: :lobby_closed,
  lobby_id: Lobby.id()
}
```

## `Teiserver.Game.Lobby:{lobby_id}`
Messages relating to updates to the lobby in question.

### User joined - `:lobby_user_joined`
Fired off whenever a user is added to the lobby member list.

- `:client` - A `Teiserver.Connections.Client` of the client

```elixir
%{
  event: :lobby_user_joined,
  lobby_id: Lobby.id(),
  client: Client.t()
}
```

### User left - `:lobby_user_left`
Indicating a user has left the lobby

- `:user_id` - The user_id of the leaver

```elixir
%{
  event: :lobby_user_left,
  lobby_id: Lobby.id(),
  user_id: User.id()
}
```


### Client state change - `:lobby_client_change`
Note this will be sent in addition to normal client updated messages but by doing this we prevent people having to subscribe/unsubscribe from client update messages.

- `:update_id` - An incremental number to allow for out of order messages
- `:client` - A `Teiserver.Connections.Client` of the new client values

```elixir
%{
  event: :client_updated,
  update_id: integer(),
  client: Client.t()
}
```

### State update - `:lobby_updated`

- `:update_id` - An incremental number to allow for out of order messages
- `:client` - A `Teiserver.Connections.Client` of the new client values

```elixir
%{
  event: :lobby_updated,
  update_id: integer(),
  lobby: Lobby.t()
}
```

### Closed - `:lobby_closed`
- `:lobby_id` - The id of the lobby closed

```elixir
%{
  event: :lobby_closed,
  lobby_id: Lobby.id()
}
```

## `Teiserver.Game.LobbyHost:{lobby_id}`
Messages specifically for hosting of the lobby. Separate from client related ones to allow for observability and greater control for users of the library.

### User requests to join - `:join_request`

