defmodule DiceWizard.Repo do
  use Ecto.Repo,
    otp_app: :dice_wizard,
    adapter: Ecto.Adapters.Postgres
end
