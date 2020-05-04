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

  def roll_factory do
    %DiceMagick.Rolls.Roll{
      name: "Constitution Save",
      character: build(:character),
      parts: build_list(1, :roll_part)
    }
  end

  def roll_part_factory do
    %DiceMagick.Rolls.Roll.Part{num: 1, sides: 20, mod: 3}
  end
end
