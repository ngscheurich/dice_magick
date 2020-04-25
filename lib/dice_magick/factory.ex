defmodule DiceMagick.Factory do
  use ExMachina.Ecto, repo: DiceMagick.Repo

  def user_factory do
    %DiceMagick.Accounts.User{
      nickname: "Bobson Dugnutt",
      discord_uid: sequence("discord")
    }
  end

  def character_factory do
    %DiceMagick.Characters.Character{
      name: "Baldur",
      user: build(:user)
    }
  end
end
