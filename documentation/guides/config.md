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


