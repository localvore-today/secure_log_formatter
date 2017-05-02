# SecureLogFormatter

A secure formatter for Elixir Logger and replacement for `Kernel.inspect/1`.  Using blacklisted keys and patterns `SecureLogFormatter` will identify and redact sensitive information from logs with ease.


## Installation

```elixir
def deps do
  [{:secure_log_formatter, "~> 0.1.0"}]
end
```

Like living on the edge?  Want the latest and greatest?

```elixir
def deps do
  [{:secure_log_formatter,
  	github: "localvore-today/secure_log_formatter"}]
end
```

## Usage

```elixir
config :logger,
  secure_log_formatter:
    [
      # Map and Keyword List keys who's value should be hidden
      fields: ["password", "credit_card", ~r/.*_token/],

      # Patterns which if found, should be hidden
      patterns: [~r/4[0-9]{15}/] # Simple credit card example

      # defaults to "[REDACTED]"
      replacement: "[PRIVATE]"
    ]
```

#### Log formatting

Using `SecureLogFormatter` is easy, we only need to pass a tuple to the `:format` option for our logging backend(s):

```elixir
config :logger,
  console: [format: {SecureLogFormatter, :format}]
```

If we give it awhirl:

```elixir
iex> Logger.info("Customer Credit Card: 4111111111111111")
15:39:40.169 [info]  Customer Credit Card: [PRIVATE]
```

#### Replacing `inspect/1`

To leverage `SecureLogFormatter.inspect/1` in place of `Kernel.inspect/1` we can add two lines to the top of our files:

```elixir
import Kernel, except: [inspect: 1]
import SecureLogFormatter, only: [inspect: 1]
```

With this change calls to `inspect/1` will be handled by `SecureLogFormatter`:

```elixir
iex> inspect(%{access_token: "secret_token", password: "abc123", username: "doomspork"})
"%{access_token: \"[PRIVATE]\", password: \"[PRIVATE]\", username: \"doomspork\"}"
```

## License

SecureLogFormatter source code is released under MIT.

See [LICENSE](LICENSE) for more information.
