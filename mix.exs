defmodule Teiserver.MixProject do
  use Mix.Project

  @github_url "https://github.com/Teifion/teiserver"
  @version "0.0.1"

  def project do
    [
      app: :teiserver,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Middleware server",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Teiserver.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_pubsub, "~> 2.1"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},

      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:argon2_elixir, "~> 3.0"},

      # Libs I expect to use
      # {:timex, "~> 3.7.5"},
      # {:parallel, "~> 0.0"},
      # {:ex_ulid, "~> 0.1.0"},
      # {:csv, "~> 2.4"},

      # Dev and Test stuff
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:excoveralls, "~> 0.15.3", only: :test, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:floki, ">= 0.34.0", only: :test},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Teifion Jordan"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@github_url}/blob/master/changelog.md",
        "GitHub" => @github_url
      }
    ]
  end
end
