use Mix.Config

patterns = [
  # Credit Cards
  ~r/#?(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})/,
  # SSN
  ~r/\d{3}-?\d{2}-?\d{4}/,
  #password in a string e.g password: "here's the secret"
  ~r/(?<=password: )(["'])(?:(?=(\\?))\2.)*?\1/
]

config :logger,
  console: [format: {SecureLogFormatter, :format}],
  secure_log_formatter:
    [patterns: patterns]
