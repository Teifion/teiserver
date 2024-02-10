# Hello World
The purpose of this guide is to show you how to create a very basic server implementing the commands `ping`, `register`, `login`, `whois`, `whoami`, `users` and `clients`. We will be using [ranch](https://ninenines.eu/docs/en/ranch/1.8/manual/) to provide a plain-text interface to our server.

Ranch is a tcp server and will allow us to provide an easy to test and prototype interface. For a more serious project you'll probably want to be looking at more structured data; for this example plain-text is fine.

## Create project
```bash
mix new --sup hello_world_server
```

## Add dependencies
In `mix.exs`
```elixir
def deps do
  [
    {:teiserver, path: "../teiserver"},
    {:ecto_sql, "~> 3.10"},
    {:postgrex, ">= 0.0.0"},
    {:thousand_island, "~> 1.3"}
  ]
end
```

Now get the relevant dependencies

```bash
mix deps.get && mix compile
```

## Create a migration
```bash
mix ecto.gen.migration add_teiserver_tables
```

And populate it like so:
```elixir
defmodule HelloWorldServer.Repo.Migrations.AddTeiserverTables do
  use Ecto.Migration

  def up do
    Teiserver.Migration.up()
  end

  def down do
    Teiserver.Migration.down(version: 1)
  end
end
```

## Application files
`lib/hello_world_server/repo.ex`
```elixir
defmodule HelloWorldServer.Repo do
  use Ecto.Repo,
    otp_app: :hello_world_server,
    adapter: Ecto.Adapters.Postgres
end
```

`config/config.exs`
```elixir
import Config

config :hello_world_server,
  ecto_repos: [HelloWorldServer.Repo]

config :hello_world_server, HelloWorldServer.Repo,
  database: "hello_world_server",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :teiserver,
  repo: HelloWorldServer.Repo
```

Edit `application.ex` to start the various components on startup.
```elixir
  children = [
    HelloWorldServer.Repo,
    {Ecto.Migrator,
        repos: Application.fetch_env!(:hello_world_server, :ecto_repos),
        skip: System.get_env("SKIP_MIGRATIONS") == "true"},

    {ThousandIsland, port: 8200, handler_module: HelloWorldServer.TcpServer}
  ]
```

## Add our tcp server
Place in `lib/hello_world_server/tcp_server.ex`
```elixir
defmodule HelloWorldServer.TcpServer do
  use ThousandIsland.Handler
  alias HelloWorldServer.{TcpIn, TcpOut}

  @impl ThousandIsland.Handler
  def handle_connection(socket, _state) do
    {:continue, %{
      user_id: nil,
      socket: socket
    }}
  end

  @impl ThousandIsland.Handler
  # If Ctrl + C is sent through it kills the connection, makes telnet debugging easier
  def handle_data(<<255, 244, 255, 253, 6>>, _socket, state) do
    {:close, state}
  end

  def handle_data(data, socket, state) do
    {new_state, response} = TcpIn.data_in(String.trim(data), state)
    TcpOut.data_out(response, new_state)
    {:continue, new_state}
  end
end
```

## Data in
Place in `lib/hellow_world_server/tcp_in.ex`, this will handle all the commands coming in.
```elixir
defmodule HelloWorldServer.TcpIn do
  alias Teiserver.Api

  def data_in("ping" <> _data, state) do
    {state, "pong"}
  end

  def data_in("login " <> data, state) do
    [name, password] = String.split(data, " ")
    case Api.maybe_authenticate_user do
      {:ok, user} ->
        Api.connect_user(user)
        {%{state | user_id: user.id}, "You are now logged in as '#{user.name}'"}
      {:error, :no_user} ->
        {state, "Login failed (no user)"}
      {:error, :bad_password} ->
        {state, "Login failed (bad password)"}
    end
  end

  def data_in("register " <> data, state) do
    [name, password] = String.split(data, " ")
    
    # We're not using emails right now but Teiserver expects them to be unique
    # this will do for the purposes of this example
    email = to_string(:rand.uniform())
    
    case Api.register_user(name, email, password) do
      {:ok, _user} ->
        {state, "User created, you can now login with 'login name password'"}
      {:error, _} ->
        {state, "Error registering user"}
    end
  end

  def data_in("whois " <> data, state) do
    case Teiserver.Account.get_user_by_name(data) do
      nil ->
        {state, "I cannot find a user by the name of '#{data}'"}
      user ->
        {state, "User #{user.name} exists with an ID of #{user.id}"}
    end
  end

  def data_in("whoami" <> _data, %{user_id: user_id} = state) do
    case Teiserver.Account.get_user_by_id(user_id) do
      nil ->
        {state, "You are not logged in"}
      user ->
        {state, "You are '#{user.name}'"}
    end
  end

  def data_in("users" <> _data, state) do
    names = Teiserver.Account.list_users(select: [:name])
    |> Enum.map(fn %{name: name} -> name end)
    |> Enum.join(", ")

    {state, "User names: #{names}"}
  end

  def data_in("clients" <> _data, state) do
    client_ids = Teiserver.Connections.list_client_ids()

    names = Teiserver.Account.list_users(where: [id_in: client_ids], select: [:name])
    |> Enum.map(fn %{name: name} -> name end)
    |> Enum.join(", ")

    {state, "Client names: #{names}"}
  end
end
```

## Data out
Place in `lib/hellow_world_server/tcp_out.ex`, this will handle sending data back to our users.
```elixir
defmodule HelloWorldServer.TcpOut do
  def data_out(msg, state) do
    ThousandIsland.Socket.send(state.socket, "#{msg}\n")
  end
end
```

# Showtime!
Get deps
We now need to run our application.
```bash
iex -S mix run --no-halt
```

This will open up a REPL into the application and we can run queries manually if we want to such as:
```elixir
Teisever.Account.list_users()
Teisever.Account.list_clients()
```

### Telnet
In another terminal we can then do:
```bash
telnet localhost 8200
# Trying 127.0.0.1...
# Connected to localhost.
# Escape character is '^]'.

ping
# pong

whoami
# You are not logged in

whois teifion
# I cannot find a user by the name of 'Teifion'

register teifion password1
# User created, you can now login with 'login name password'

whois teifion
# User Teifion exists with an ID of 1

login teifion nopass
# Login failed (bad password)

login teifion password1
# You are now logged in as Teifion

whoami
# You are 'Teifion'

register bob password1
# User created, you can now login with 'login name password'

users
# User names: teifion, bob

clients
# Client names: teifion
```
