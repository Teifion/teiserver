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

# Users
## default_behaviour_score - Default: `10_000`
The `behaviour_score` given to users registered using `Teiserver.Account.UserLib.register_user/1`.

## default_trust_score - Default: `10_000`
The `trust_score` given to users registered using `Teiserver.Account.UserLib.register_user/1`.

## default_social_score - Default: `10_000`
The `social_score` given to users registered using `Teiserver.Account.UserLib.register_user/1`.

## default_min_user_password_length - Default: 6
The minimum length for a user password.

# Clustering
## `teiserver_clustering` - Default: true
When enabled Teiserver will attempt to handle the clustering of nodes using a database table. Turning it off will mean this behaves like any other application and you can either not cluster it or use things like `libcluster` as you desire. See `Teiserver.System.ClusterManager` for more details.

## `teiserver_clustering_post_join_functions` - Default: []
When teiserver_clustering is enabled, this will be a list of functions called by the genserver handling the join once it has joined the cluster. See `Teiserver.System.ClusterManager` for more details.

# Function overrides
Teiserver implements some defaults you may want to overwrite.

## `fn_calculate_match_type`
Allows you to overwrite `Teiserver.Game.MatchTypeLib.default_calculate_match_type/1`. This is used to determine the type assigned to each match. By default a 2 player game is a `Duel` and anything else is a `Team` game.

## `fn_calculate_user_permissions`
Allows you to overwrite `Teiserver.Account.User.default_calculate_user_permissions/1`. This is used to generate the list of permissions held by a user. By default it mirrors their groups.

## `fn_lobby_name_acceptor`
A function used to determine if a lobby name is acceptable. Defaults to `Teiserver.Game.LobbyLib.default_lobby_name_acceptable/1` which always returns true.

## `fn_user_name_acceptor`
A function used to determine if a lobby name is acceptable. Defaults to `Teiserver.Account.UserLib.default_user_name_acceptable/1` which always returns true.


# Complete example config
```elixir
config :teiserver,
  repo: HelloWorldServer.Repo,
  client_destroy_timeout_seconds: 300,
  lobby_join_method: :simple,
  teiserver_clustering: true,

  # Users
  default_behaviour_score: 10_000,
  default_trust_score: 10_000,
  default_social_score: 10_000,

  # Overrides
  fn_calculate_match_type: &HelloWorldServer.Game.calculate_match_type/1,
  fn_calculate_user_permissions: &HelloWorldServer.Account.calculate_user_permissions/1,
  
  fn_lobby_name_acceptor: &HelloWorldServer.Account.lobby_name_acceptor/1,
  fn_user_name_acceptor: &HelloWorldServer.Account.user_name_acceptor/1,
```
