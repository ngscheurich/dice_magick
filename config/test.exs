use Mix.Config

# Configure your database
config :dice_wizard, DiceWizard.Repo,
  username: "postgres",
  password: "postgres",
  database: "dice_wizard_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dice_wizard, DiceWizardWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
