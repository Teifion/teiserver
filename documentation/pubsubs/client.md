`Teiserver.ClientServer:{user_id}`

### Updated client
Fired whenever the client is updated.

- `:update_id` - An incremental number to allow for out of order messages
- `:client` - A `Teiserver.Connections.Client` of the new client values

```elixir
%{
  event: :client_updated,
  update_id: integer(),
  client: Client.t()
}
```

