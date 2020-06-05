defmodule DiceMagick.DiceTest do
  use ExUnit.Case, async: true

  alias DiceMagick.Dice
  alias Dice.Outcome

  test "roll/1 returns the expected value" do
    assert Dice.roll("1") == %Outcome{total: 1, rolls: []}
    assert Dice.roll("1 + 2 - 4") == %Outcome{total: -1, rolls: []}
    assert %Outcome{rolls: rolls} = Dice.roll("1d20 + 2d8 + 3")
    assert Enum.count(rolls) == 3
  end
end
