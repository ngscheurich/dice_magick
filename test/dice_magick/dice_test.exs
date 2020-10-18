defmodule DiceMagick.DiceTest do
  use ExUnit.Case, async: true

  alias DiceMagick.Dice
  alias Dice.Result

  test "roll/1 with valid input returns success tuple" do
    assert Dice.evaluate("1") == {:ok, %Result{expression: "1", total: 1, faces: []}}

    assert Dice.evaluate("1 + 2 - 4") ==
             {:ok, %Result{expression: "1 + 2 - 4", total: -1, faces: []}}

    assert {:ok, %Result{faces: faces}} = Dice.evaluate("1d20 + 2d8 + 3")
    assert Enum.count(faces) == 3
  end

  test "roll/1 with invalid input returns error tuple" do
    assert Dice.evaluate("x") == {:error, :invalid_expression}
    assert Dice.evaluate("1 * 2 - 4") == {:error, :invalid_expression}
  end

  test "roll!/1 width valid input returns outcome" do
    assert %Result{faces: faces} = Dice.evaluate!("1d20 + 2d8 + 3")
    assert Enum.count(faces) == 3
  end

  test "roll/1 with invalid input raises" do
    assert_raise ArgumentError, fn ->
      Dice.evaluate!("1 * 2 - 4")
    end
  end
end
