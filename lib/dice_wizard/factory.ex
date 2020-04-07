defmodule DiceWizard.Factory do
  use ExMachina.Ecto, repo: DiceWizard.Repo

  def user_factory do
    %DiceWizard.Accounts.User{
      nickname: "Bobson Dugnutt",
      discord_uid: "discord"
    }
  end
end
