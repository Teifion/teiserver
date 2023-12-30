defmodule Teiserver.MixProject do
  use Mix.Project

  @source_url "https://github.com/Teifion/teiserver"
  @version "0.0.1"

  def project do
    [
      app: :teiserver,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # aliases: aliases(),
      preferred_cli_env: [
        bench: :test,
        "test.ci": :test,
        "test.reset": :test,
        "test.setup": :test
      ],

      # Hex
      description: "Game middleware server",
      package: package(),

      # Docs
      name: "Teiserver",
      docs: [
        main: "Teiserver",
        api_reference: false,
        # logo: "assets/teiserver-logo.svg",
        source_ref: "v#{@version}",
        source_url: @source_url,
        extra_section: "GUIDES",
        formatters: ["html"],
        extras: extras(),
        groups_for_extras: groups_for_extras(),
        groups_for_modules: groups_for_modules(),
        groups_for_docs: groups_for_docs(),
        skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
      ]
    ]
  end

  defp extras do
    [
      # Guides
      "guides/installation.md",
      "guides/hello_world.md",
      # "guides/troubleshooting.md",
      # "guides/release_configuration.md",
      # "guides/writing_plugins.md",
      # "guides/upgrading/v2.0.md",
      # "guides/upgrading/v2.6.md",
      # "guides/upgrading/v2.11.md",
      # "guides/upgrading/v2.12.md",
      # "guides/upgrading/v2.14.md",
      # "guides/upgrading/v2.17.md",

      # # Recipes
      # "guides/recipes/recursive-jobs.md",
      # "guides/recipes/reliable-scheduling.md",
      # "guides/recipes/reporting-progress.md",
      # "guides/recipes/expected-failures.md",
      # "guides/recipes/splitting-queues.md",
      # "guides/recipes/migrating-from-other-languages.md",

      # # Testing
      # "guides/testing/testing.md",
      # "guides/testing/testing_workers.md",
      # "guides/testing/testing_queues.md",
      # "guides/testing/testing_config.md",
      "CHANGELOG.md": [title: "Changelog"]
    ]
  end

  defp groups_for_extras do
    [
      Guides: ~r{guides/[^\/]+\.md}
      # Recipes: ~r{guides/recipes/.?},
      # Testing: ~r{guides/testing/.?},
      # "Upgrade Guides": ~r{guides/upgrading/.*}
    ]
  end

  defp groups_for_modules do
    [
      Contexts: [
        Teiserver.Account,
        Teiserver.Settings
      ],
      Account: [
        ~r"Teiserver.Account.*"
      ],
      Settings: [
        ~r"Teiserver.Settings.*"
      ]
    ]
  end

  def groups_for_docs do
    [
      # Accounts
      Users: &(&1[:section] == :user),
      "Extra user data": &(&1[:section] == :extra_user_data),

      # Settings
      "Site settings": &(&1[:section] == :site_setting),
      "User settings": &(&1[:section] == :user_setting)
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
      licenses: ["Apache-2.0"],
      files: ~w(lib .formatter.exs mix.exs README* CHANGELOG* LICENSE*),
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url,
        "Discord" => "https://discord.gg/NmrSt9zw2p"
      }
    ]
  end

  # Oban has these and seems to do a really nice job so we're going to use them too
  # defp aliases do
  #   [
  #     bench: "run bench/bench_helper.exs",
  #     release: [
  #       "cmd git tag v#{@version}",
  #       "cmd git push",
  #       "cmd git push --tags",
  #       "hex.publish --yes"
  #     ],
  #     "test.reset": ["ecto.drop --quiet", "test.setup"],
  #     "test.setup": ["ecto.create --quiet", "ecto.migrate --quiet"],
  #     "test.ci": [
  #       "format --check-formatted",
  #       "deps.unlock --check-unused",
  #       "credo --strict",
  #       "test --raise",
  #       "dialyzer"
  #     ]
  #   ]
  # end
end
