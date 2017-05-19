import Kernel, except: [inspect: 1]

defmodule SecureLogFormatter do
  @moduledoc """
  Documentation for SecureLogFormatter.
  """

  alias Logger.Formatter

  @default_fields [~r/\w*_token/, "credit_card", "password"]
  @default_pattern "\n$time $metadata[$level] $levelpad$message\n"

  config = Application.get_env(:logger, :secure_log_formatter, [])
  @fields Keyword.get(config, :fields, []) ++ @default_fields
  @label Keyword.get(config, :replacement, "[REDACTED]")
  @patterns Keyword.get(config, :patterns, [])
  @format_config config
    |> Keyword.get(:format, @default_pattern)
    |> Formatter.compile

  def default_fields, do: @default_fields

  @doc """
  Secure formatting for Elixir Logger

  # Examples

      iex> SecureLogFormatter.format(:info, "CC 4111111111111111", nil, [])
      ["\\n", :time, " ", "", "[", "info", "] ", " ", "CC [REDACTED]", "\\n"]
  """
  def format(level, msg, ts, md),
    do: Formatter.format(@format_config, level, sanitize(msg), ts, md)

  @doc """
  Securely inspect a value.

  # Examples

      iex> SecureLogFormatter.inspect(%{user: "username", password: "abc123"})
      ~s(%{password: \"[REDACTED]\", user: \"username\"})

      iex> SecureLogFormatter.inspect([access_token: "secret"])
      ~s([access_token: \"[REDACTED]\"])

      iex> SecureLogFormatter.inspect("Customer CC 4111111111111111")
      ~s("Customer CC [REDACTED]")
  """
  def inspect(message) do
    message
    |> sanitize
    |> Kernel.inspect
  end

  @doc """
  Sanitize the input value.

  # Examples

      iex> SecureLogFormatter.sanitize(%{user: "username", password: "abc123"})
      %{password: \"[REDACTED]\", user: \"username\"}

      iex> SecureLogFormatter.sanitize([access_token: "secret"])
      [access_token: \"[REDACTED]\"]

      iex> SecureLogFormatter.sanitize("Customer CC 4111111111111111")
      "Customer CC [REDACTED]"
  """
  def sanitize(data) when is_binary(data) do
    Enum.reduce(@patterns, data, &Regex.replace(&1, &2, @label))
  end

  def sanitize(data) when is_list(data) do
    Enum.map(data, &sanitize/1)
  end

  def sanitize(data) when is_map(data) do
    data
    |> Enum.map(&sanitize/1)
    |> Enum.into(%{})
  end

  def sanitize({key, value}) do
    if censor_field?(key) do
      {key, @label}
    else
      {key, sanitize(value)}
    end
  end

  def sanitize(other), do: other

  defp censor_field?(key) do
    normalized =
      key
      |> to_string
      |> String.replace(" ", "_")
      |> String.downcase

    Enum.any?(@fields, &key_match?(&1, normalized))
  end

  defp key_match?(pattern, pattern), do: true
  defp key_match?(pattern, _) when is_binary(pattern), do: false
  defp key_match?(pattern, key), do: Regex.match?(pattern, key)
end
