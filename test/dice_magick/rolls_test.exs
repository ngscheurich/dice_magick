defmodule DiceMagick.RollsTest do
  use DiceMagick.DataCase

  alias DiceMagick.Rolls

  describe "rolls" do
    alias Rolls.{Roll, Roll.Part}

    test "create_roll/1 with valid data creates a roll" do
      character = insert(:character)

      assert {:ok, %Roll{} = roll} =
               Rolls.create_roll(%{
                 name: "Sneak Attack",
                 parts: [%{num: 1, sides: 20, mod: 3}, %{num: 1, sides: 6, mod: 0}],
                 character_id: character.id
               })

      assert roll.name == "Sneak Attack"
      assert [%Part{num: 1, sides: 20, mod: 3}, %Part{num: 1, sides: 6, mod: 0}] = roll.parts
      assert roll.character_id == character.id
    end

    test "create_roll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Rolls.create_roll(%{name: nil, parts: nil, character_id: nil})
    end
  end
end
