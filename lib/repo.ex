defmodule Repo do
  use Ecto.Repo,
    otp_app: :dice_magick,
    adapter: Ecto.Adapters.Postgres
end
