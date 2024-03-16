# Snippets

## User authentication and login
Given a `name` and `password` we want to log a user in.

```elixir
@spec connect_user(String.t(), String.t()) :: {:ok, Teiserver.Account.User.t()} | {:error, String.t()}
def connect_user(name, password) do
  case Teiserver.Account.get_user_by_name(name) do
    nil ->
      {:error, "User not found"}
    user ->
      if Teiserver.Account.valid_password?(user, password) do
        Teiserver.Connections.connect_user(user)
        {:ok, user}
      else
        {:error, "Invalid password"}
      end
  end
end
```

