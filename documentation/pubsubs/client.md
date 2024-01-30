# Client messages
PubSub messages sent out in relation to changes to the client in question.

## `Teiserver.Connections.Client:{user_id}`
The pubsub messages received by anybody watching this account. By default logging in will subscribe you to these messages.

### Updated client
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

