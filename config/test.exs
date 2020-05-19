use Mix.Config

config :dice_magick, google_sheets: DiceMagick.GoogleSheets.InMemory

# Configure your database
config :dice_magick, DiceMagick.Repo,
  username: "postgres",
  password: "postgres",
  database: "dice_magick_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dice_magick, DiceMagickWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
