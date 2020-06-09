defmodule DiceMagick.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :dice_magick,
      version: @version,
      elixir: "~> 1.5",
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      source_url: "https://github.com/ngscheurich/dice_magick",
      homepage_url: "https://www.dice_magick.app",

      # Docs
      name: "DiceMagick",
      docs: docs()
    ]
  end

  def application do
    [
      mod: {DiceMagick.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:assert_identity, "~> 0.1.0"},
      {:cowlib, "~> 2.8.0", override: true},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.1"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:ex_machina, "~> 2.4"},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.1"},
      {:nimble_csv, "~> 0.6"},
      {:nimble_parsec, "~> 0.5"},
      {:nostrum, "~> 0.4"},
      {:phoenix, "~> 1.5.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.12.1"},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.2"},
      {:postgrex, ">= 0.0.0"},
      {:sentry, "~> 7.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:timex, "~> 3.0"},
      {:ueberauth_discord, "~> 0.5"}
    ]
  end

  defp docs do
    [
      main: "DiceMagick",
      authors: ["N. G. Scheurich <nick@scheurich.me>"],
      logo: "logo.png",
      groups_for_modules: [
        DiceMagick: [
          DiceMagick.Accounts,
          DiceMagick.Accounts.User,
          DiceMagick.Characters,
          DiceMagick.Characters.Character,
          DiceMagick.Characters.Supervisor,
          DiceMagick.Characters.Worker,
          DiceMagick.Characters.Worker.State,
          DiceMagick.Rolls,
          DiceMagick.Rolls.Roll,
          DiceMagick.Rolls.Result
        ],
        "Discord Bot": [
          DiceMagick.Discord.Command,
          DiceMagick.Discord.Create,
          DiceMagick.Discord.Roll,
          DiceMagick.Discord.Sync
        ],
        "Data Sources": [
          DiceMagick.Sources.Source,
          DiceMagick.Sources.GoogleSheets,
          DiceMagick.Sources.Test,
          DiceMagick.GoogleSheets.HTTPClient
        ],
        "Web Interface": [
          DiceMagickWeb.Auth,
          DiceMagickWeb.CharacterController,
          DiceMagickWeb.SessionController,
          DiceMagickWeb.ErrorHelpers,
          DiceMagickWeb.Router.Helpers
        ],
        Enums: [
          DataFormatEnum,
          SourceTypeEnum
        ]
      ],
      nest_modules_by_prefix: [
        DiceMagick.Characters,
        DiceMagick.GoogleSheets,
        DiceMagick.Sources,
        DiceMagickWeb
      ],
      extras: ["README.md"]
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
