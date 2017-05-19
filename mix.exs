defmodule SecureLogFormatter.Mixfile do
  use Mix.Project

  @version "1.1.0"

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
    [
      # Development and Test dependencies
      {:localvore_credo_checks,
        github: "localvore-today/localvore-credo-checks", only: [:dev, :test]},
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Sean Callan"],
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/localvore-today/secure_log_formatter"
      },
      files: ~w(lib mix.exs README.md LICENSE)
    ]
  end
end
