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
                 parts: [%{num: 1, die: 20, mod: 3}, %{num: 1, die: 6, mod: 0}],
                 character_id: character.id
               })

      assert roll.name == "Sneak Attack"
      assert roll.parts == [%{num: 1, die: 20, mod: 3}, %{num: 1, die: 6, mod: 0}]
      assert roll.character == character
    end

    test "create_roll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Rolls.create_roll(%{name: nil, parts: nil, character_id: nil})
    end
  end
end
