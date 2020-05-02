defmodule DiceMagick.Sources.CSVTest do
  use ExUnit.Case

  alias DiceMagick.Sources.CSV
  alias DiceMagick.Rolls.Roll

  test "encode/1 with valid data returns encoded rolls" do
    csv = """
    Wisdom Save,"1d20 + 4"
    Sneak Attack,"1d20 + 3, 1d6"
    Cursed Greatsword,"1d10 - 1"
    """

    assert CSV.encode(csv) ==
             {:ok,
              [
                %Roll{name: "Wisdom Save", parts: [{1, 20, 4}]},
                %Roll{name: "Sneak Attack", parts: [{1, 20, 3}, {1, 6, 0}]},
                %Roll{name: "Cursed Greatsword", parts: [{1, 10, -1}]}
              ]}
  end

  test "encode/1 with invalid data returns error" do
    csv = """
    Wisdom Save,"1d20, 4"
    """

    assert {:error, _} = CSV.encode(csv)
  end
end
