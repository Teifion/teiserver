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
    {:ranch, "~> 1.8"}
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

config :hello_world_server, Teiserver,
  repo: HelloWorldServer.Repo
```

Edit `application.ex` to start the various components on startup.
```elixir
  children = [
    HelloWorldServer.Repo,
    {Ecto.Migrator,
        repos: Application.fetch_env!(:hello_world_server, :ecto_repos),
        skip: System.get_env("SKIP_MIGRATIONS") == "true"},
    {Teiserver, Application.get_env(:hello_world_server, Teiserver)},
    %{
      id: HelloWorldServer.TcpServer,
      start: {HelloWorldServer.TcpServer, :start_link, [[]]}
    }
  ]
```

## Add our tcp server
Place in `lib/hello_world_server/tcp_server.ex`
```elixir
defmodule HelloWorldServer.TcpServer do
  use GenServer
  alias HelloWorldServer.{TcpIn, TcpOut}
  @behaviour :ranch_protocol

  def start_link(_opts) do
    :ranch.start_listener(
      make_ref(),
      :ranch_tcp,
      [port: 8200],
      __MODULE__,
      []
    )
  end

  @impl true
  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(ref, socket, transport) do
    :ranch.accept_ack(ref)
    transport.setopts(socket, [{:active, true}])

    state = %{
      user_id: nil,
      socket: socket,
      transport: transport,
    }

    :gen_server.enter_loop(__MODULE__, [], state)
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def handle_info(:init_timeout, %{userid: nil} = state) do
    send(self(), :terminate)
    {:noreply, state}
  end

  def handle_info(:init_timeout, state) do
    {:noreply, state}
  end

  # If Ctrl + C is sent through it kills the connection, makes telnet debugging easier
  def handle_info({_, _socket, <<255, 244, 255, 253, 6>>}, state) do
    send(self(), :terminate)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, state) do
    data = data
    |> to_string
    |> String.trim

    {new_state, response} = TcpIn.data_in(data, state)
    TcpOut.data_out(response, state)
    {:noreply, new_state}
  end
end
```

## Data in
Place in `lib/hellow_world_server/tcp_in.ex`, this will handle all the commands coming in.
```elixir
defmodule HelloWorldServer.TcpIn do
  def data_in("ping" <> _data, state) do
    {state, "pong"}
  end

  def data_in("login " <> data, state) do
    [name, password] = String.split(data, " ")
    case Teiserver.Account.get_user_by_name(name) do
      nil ->
        {state, "Login failed (no user)"}
      user ->
        if Teiserver.Account.verify_user_password(user, password) do
          Teiserver.Connections.connect_user(user)
          {%{state | user_id: user.id}, "You are now logged in as '#{user.name}'"}
        else
          {state, "Login failed (bad password)"}
        end
    end
  end

  def data_in("register " <> data, state) do
    [name, password] = String.split(data, " ")
    params = %{
      "name" => name,
      "password" => password,

      # We're not using emails right now but Teiserver expects them to be unique
      # this will do for the purposes of this example
      "email" => to_string(:rand.uniform())
    }

    case Teiserver.Account.create_user(params) do
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

  def data_in("users" <> _data, %{user_id: user_id} = state) do
    names = Teiserver.Account.list_users(select: [:name])
    |> Enum.map(fn %{name: name} -> name end)
    |> Enum.join(", ")

    {state, "User names: #{names}"}
  end

  def data_in("clients" <> _data, %{user_id: user_id} = state) do
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
    state.transport.send(state.socket, msg <> "\n")
  end
end
```

# Showtime!
Get deps
We now need to run our application.
```bash
mix run --no-halt
```

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
