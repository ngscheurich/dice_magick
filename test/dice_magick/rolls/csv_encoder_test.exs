defmodule DiceMagick.Sources.CSVEncoderTest do
  use ExUnit.Case

  alias DiceMagick.Rolls.{Roll, Roll.Part, CSVEncoder}

  test "encode/1 with valid data returns encoded rolls" do
    csv = """
    Wisdom Save,1d20 + 4
    Sneak Attack,1d20 + 3 & 1d6
    Cursed Greatsword,1d10 - 1
    """

    assert CSVEncoder.encode(csv) ==
             {:ok,
              [
                %Roll{name: "Wisdom Save", parts: [%Part{num: 1, sides: 20, mod: 4}]},
                %Roll{
                  name: "Sneak Attack",
                  parts: [%Part{num: 1, sides: 20, mod: 3}, %Part{num: 1, sides: 6, mod: 0}]
                },
                %Roll{name: "Cursed Greatsword", parts: [%Part{num: 1, sides: 10, mod: -1}]}
              ]}
  end

  test "encode/1 with invalid data returns error" do
    csv = ~s(Wisdom Save,1d20 & 4)
    assert {:error, _} = CSVEncoder.encode(csv)
  end
end
