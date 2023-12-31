# Snippets

## User authentication and login
Given a `name` and `password` we want to log a user in.

```elixir
@spec login_user(String.t(), String.t()) :: {:ok, Teiserver.Account.User.t()} | {:error, String.t()}
def login_user(name, password) do
  case Teiserver.Account.get_user_by_name(name) do
    nil ->
      {:error, "User not found"}
    user ->
      if Teiserver.Account.verify_user_password(user, password) do
        Teiserver.Connections.login_user(user)
        {:ok, user}
      else
        {:error, "Invalid password"}
      end
  end
end
```

## User logout
```elixir
Teiserver.Connections.disconnect_user(user)
```

