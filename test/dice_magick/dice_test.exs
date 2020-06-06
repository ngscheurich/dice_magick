defmodule DiceMagick.DiceTest do
  use ExUnit.Case, async: true

  alias DiceMagick.Dice
  alias Dice.Outcome

  test "roll/1 with valid input returns success tuple" do
    assert Dice.roll("1") == {:ok, %Outcome{total: 1, rolls: []}}
    assert Dice.roll("1 + 2 - 4") == {:ok, %Outcome{total: -1, rolls: []}}
    assert {:ok, %Outcome{rolls: rolls}} = Dice.roll("1d20 + 2d8 + 3")
    assert Enum.count(rolls) == 3
  end

  test "roll/1 with invalid input returns error tuple" do
    assert Dice.roll("x") == {:error, :invalid_expression}
    assert Dice.roll("1 * 2 - 4") == {:error, :invalid_expression}
  end

  test "roll!/1 width valid input returns outcome" do
    assert %Outcome{rolls: rolls} = Dice.roll!("1d20 + 2d8 + 3")
    assert Enum.count(rolls) == 3
  end

  test "roll/1 with invalid input raises" do
    assert_raise ArgumentError, fn ->
      Dice.roll!("1 * 2 - 4")
    end
  end
end
