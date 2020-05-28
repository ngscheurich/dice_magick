defmodule Factory do
  @moduledoc """
  [todo] Add documentation.
  """

  use ExMachina.Ecto, repo: Repo

  def user_factory do
    %Accounts.User{
      nickname: "Bobson Dugnutt",
      discord_uid: sequence("discord")
    }
  end

  def character_factory do
    %Characters.Character{
      name: "Baldur",
      source_type: :test,
      source_params: %{"test" => true},
      user: build(:user)
    }
  end

  def roll_factory do
    %Rolls.Roll{
      name: "Constitution Save",
      expression: "1d20 + 5"
    }
  end

  def result_factory do
    %Rolls.Result{
      name: "Stealth Check",
      expression: "1d20 + 9",
      outcome: 23,
      character: build(:character)
    }
  end
end
