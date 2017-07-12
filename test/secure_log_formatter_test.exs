defmodule SecureLogFormatterTest do
  use ExUnit.Case
  doctest SecureLogFormatter

  require Logger

  import ExUnit.CaptureLog
  import Kernel, except: [inspect: 1]
  import SecureLogFormatter, only: [inspect: 1]

  describe "inspect/1" do
    test "securely inspects maps" do
      assert inspect(%{username: "doomspork", password: "abc123"}) =~ "password: \"[REDACTED]\""
    end

    test "securely inspects keyword lists" do
      assert inspect([credit_card: "4111111111111111"]) =~ "[credit_card: \"[REDACTED]\"]"
    end
  end

  describe "log formatting" do
    test "replaces sensitive values when logging binaries" do
      assert capture_log(fn ->
        Logger.info("Credit card #4111111111111111")
      end) =~ "Credit card [REDACTED]"
    end

    test "replaces secure values in lists" do
      assert capture_log(fn ->
        Logger.info(["credit card", "4111111111111111"])
      end) =~ "[REDACTED]"
    end
  end

  describe "sanitize/1" do
    test "sanitizes improper lists" do
      improper_list = [{:password, "abc123"}, {:username, "doomspork"} | {:credit_card, "4111111111111111"}]
      assert SecureLogFormatter.sanitize(improper_list) == [{:password, "[REDACTED]"}, {:username, "doomspork"} | {:credit_card, "[REDACTED]"}]
    end

    test "sanitizes charlists" do
      assert SecureLogFormatter.sanitize('password: "secret"') == "password: [REDACTED]"
    end
  end
end
