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
      source_type: :test,
      source_params: %{"test" => true},
      user: build(:user)
    }
  end

  def roll_factory do
    %DiceMagick.Rolls.Roll{
      name: "Constitution Save",
      expression: "1d20 + 5",
      character: build(:character)
    }
  end
end
