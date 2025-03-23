# ExBanking

ExBanking is a simple banking application written in Elixir. It allows users to create accounts, deposit and withdraw money, and transfer funds between accounts.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_banking` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_banking, "~> 0.1.0"}
  ]
end
```

## Usage

To start using ExBanking, you need to start the application and create a user account:

```elixir
# Start the application by console
`iex -S mix`

# Create a new user
ExBanking.create_user("john_doe")

# Deposit money into the user's account
ExBanking.deposit("john_doe", 100, "USD")

# Withdraw money from the user's account
ExBanking.withdraw("john_doe", 50, "USD")

# Transfer money to another user
ExBanking.create_user("jane_doe")
ExBanking.send("john_doe", "jane_doe", 25, "USD")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_banking>.

