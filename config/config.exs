# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dice_magick,
  ecto_repos: [DiceMagick.Repo],
  generators: [binary_id: true],
  google_sheets: DiceMagick.GoogleSheets.HTTPClient

# Configures the endpoint
config :dice_magick, DiceMagickWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qFN2SYdwyU3kFUFKBwes2Z2jgUMiblp5XqW/YEjwWK0AfyTwEe9sKp69LfAEdaju",
  render_errors: [view: DiceMagickWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: PubSub,
  live_view: [signing_salt: "J3lKKxgK"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth, providers: [discord: {Ueberauth.Strategy.Discord, []}]

config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
  client_id: System.get_env("DISCORD_CLIENT_ID"),
  client_secret: System.get_env("DISCORD_CLIENT_SECRET")

config :nostrum,
  token: System.get_env("DISCORD_BOT_TOKEN")

config :logger,
  backends: [:console, Sentry.LoggerBackend]

config :goth, json: System.get_env("GCP_CREDENTIALS")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
