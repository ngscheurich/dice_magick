defmodule DiceMagick.MixProject do
  use Mix.Project

  def project do
    [
      app: :dice_magick,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Docs
      name: "DiceMagick",
      source_url: "https://github.com/ngscheurich/dice_magick",
      homepage_url: "https://github.com/ngscheurich/dice_magick",
      docs: [
        main: "DiceMagick",
        authors: ["N. G. Scheurich <nick@scheurich.me>"],
        # [todo] Add logo
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DiceMagick.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:assert_identity, "~> 0.1.0"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.1"},
      {:ex_dice_roller, "~> 1.0.0-rc.2"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:ex_machina, "~> 2.4"},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.0"},
      {:nimble_csv, "~> 0.6"},
      {:nimble_parsec, "~> 0.5"},
      {:phoenix, "~> 1.5.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.12.1"},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.2"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:ueberauth_discord, "~> 0.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
