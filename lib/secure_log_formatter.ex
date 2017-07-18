import Kernel, except: [inspect: 1]

defmodule SecureLogFormatter do
  @moduledoc """
  Documentation for SecureLogFormatter.
  """

  alias Logger.Formatter

  @default_fields [~r/\w*_token/, "credit_card", "password"]
  @default_pattern "\n$time $metadata[$level] $levelpad$message\n"

  def default_fields, do: @default_fields

  @doc """
  Secure formatting for Elixir Logger

  # Examples

      iex> SecureLogFormatter.format(:info, "CC 4111111111111111", nil, [])
      ["\\n", :time, " ", "", "[", "info", "] ", " ", "CC [REDACTED]", "\\n"]
  """
  def format(level, msg, ts, md),
    do: Formatter.format(format_config(), level, sanitize(msg), ts, md)

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
    Enum.reduce(blacklisted_patterns(), data, &replace/2)
  end

  def sanitize(data) when is_list(data) do
    if :io_lib.deep_char_list(data) do
      data |> to_string() |> sanitize()
    else
      sanitize_list(data, [])
    end
  end

  def sanitize(data) when is_map(data) do
    data
    |> Enum.map(&sanitize/1)
    |> Enum.into(%{})
  end

  def sanitize({key, value}) do
    if censor_field?(key) do
      {key, replacement()}
    else
      {key, sanitize(value)}
    end
  end

  def sanitize(other), do: other

  def sanitize_list([], acc), do: Enum.reverse(acc)
  def sanitize_list([data | rest], acc), do: sanitize_list(rest, [sanitize(data) | acc])
  def sanitize_list(improper_tail, acc), do: Enum.reverse(acc) ++ sanitize(improper_tail)

  defp blacklisted_fields, do: Keyword.get(config(), :fields, @default_fields)

  defp blacklisted_patterns, do: Keyword.get(config(), :patterns, [])

  defp censor_field?(key) do
    normalized =
      key
      |> to_string
      |> String.replace(" ", "_")
      |> String.downcase

    Enum.any?(blacklisted_fields(), &key_match?(&1, normalized))
  end

  defp config, do: Application.get_env(:logger, :secure_log_formatter, [])

  defp format_config do
    config()
    |> Keyword.get(:format, @default_pattern)
    |> Formatter.compile
  end

  defp key_match?(pattern, pattern), do: true
  defp key_match?(pattern, _) when is_binary(pattern), do: false
  defp key_match?(pattern, key), do: Regex.match?(pattern, key)

  defp replace(pattern, value), do: Regex.replace(pattern, value, replacement())

  defp replacement, do: Keyword.get(config(), :replacement, "[REDACTED]")
end
