defmodule DiceMagick.RollsTest do
  use DiceMagick.DataCase

  alias DiceMagick.Rolls

  describe "rolls" do
    alias Rolls.Roll

    test "create_roll/1 with valid data creates a roll" do
      character = insert(:character)

      assert {:ok, %Roll{} = roll} =
               Rolls.create_roll(%{
                 name: "Sneak Attack",
                 expression: "1d20 + 4 + 1d6",
                 character_id: character.id
               })

      assert roll.name == "Sneak Attack"
      assert roll.expression == "1d20 + 4 + 1d6"
      assert roll.character_id == character.id
    end

    test "create_roll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Rolls.create_roll(%{name: nil, expression: nil, character_id: nil})
    end
  end
end
