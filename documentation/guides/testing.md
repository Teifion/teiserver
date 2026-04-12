# Testing
Teiserver aims to have as many functions tested as possible. More importantly Teiserver supplies a number of fixtures and functions to make the life of anybody testing it easier.

## Fixtures
Teiserver includes at least one fixture for every schema located in `/test/support/fixtures`. They follow a consistent naming pattern:
```elixir
Teiserver.Account.User -> Teiserver.Fixtures.AccountFixtures.user_fixture()
Teiserver.Game.Match -> Teiserver.GameFixtures.incomplete_match_fixture()
```

Each fixture can be called as is or with a map which will dictate overrides for otherwise static or random values.

```elixir
Teiserver.Fixtures.AccountFixtures.user_fixture(%{
  name: "MySpecific TestUser",
  password: "A special password"
})
```

## Dummy data
Servers are much easier to debug or test when you have actual data. As such Teiserver has a number of functions dedicated to providing dummy data.

TODO: Write docs for these, located in `/test/support/dummy_data`

