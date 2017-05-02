defmodule SecureLogFormatter.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [app: :secure_log_formatter,
     build_embedded: Mix.env == :prod,
     deps: deps(),
     description: "Secure inspection and log formatting.",
     elixir: "~> 1.4",
     package: package(),
     start_permanent: Mix.env == :prod,
     version: @version]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    []
  end

  defp package do
    [
      contributors: ["Sean Callan"],
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/localvore-today/secure_log_formatter"
      },
      files: ~w(lib mix.exs README.md LICENSE)
    ]
  end
end
