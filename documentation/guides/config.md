# Config options
Teiserver config options all exist in the `:teiserver` namespace such as:

```elixir
config :teiserver,
  repo: HelloWorldServer.Repo,
  client_destroy_timeout_seconds: 300
```

## `repo` - Required
The repo used by Teiserver.

## `client_destroy_timeout_seconds` - Default: `300`
After all connections disconnect a client server process will terminate itself. This value is the number of seconds after that last disconnection and the termination. If a connection is re-established the timeout is cancelled and restarted from 0 if all connections later disconnect again.

## `lobby_join_method` - Default: `:simple`
The process for which players are able to join lobbies, can be set to `:simple` or `:host_approval`.

`:simple` means all requests to join lobbies are approved by Teiserver.

`:host_approval` means all requests to join lobbies are first approved by Teiserver but then approved by the host client. This means you will need to implement the relevant messaging and handling for clients hosting lobbies to be able to approve join requests.

# Overrides
Teiserver implements some defaults you may want to overwrite.

## `fn_calculate_match_type`
Allows you to overwrite `Teiserver.Game.MatchTypeLib.default_calculate_match_type/1`. This is used to determine the type assigned to each match. By default a 2 player game is a `Duel` and anything else is a `Team` game.



# Complete example config
```elixir
config :teiserver,
  repo: HelloWorldServer.Repo,
  client_destroy_timeout_seconds: 300,
  
  lobby_join_method: :simple,
  
  # Overrides
  fn_calculate_match_type: &HelloWorldServer.Game.calculate_match_type/1
```
