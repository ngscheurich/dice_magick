defmodule DiceMagick.RollsTest do
  use DiceMagick.DataCase
  alias DiceMagick.Rolls

  describe "results" do
    alias Rolls.Result

    test "create_result/1 with valid data creates a roll result" do
      character = insert(:character)

      assert {:ok, %Result{} = result} =
               Rolls.create_result(%{
                 name: "Sneak Attack",
                 expression: "1d20 + 4 + 1d6",
                 total: 28,
                 faces: [18, 6],
                 favorite: true,
                 tags: ["combat", "dex"],
                 character_id: character.id
               })

      assert result.name == "Sneak Attack"
      assert result.expression == "1d20 + 4 + 1d6"
      assert result.total == 28
      assert result.faces == [18, 6]
      assert result.favorite == true
      assert result.tags == ["combat", "dex"]
      assert result.character_id == character.id
    end

    test "create_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Rolls.create_result(%{name: nil, expression: nil, result: nil, character_id: nil})
    end

    test "create_result/1 with invalid expression returns error changeset" do
      character = insert(:character)
      params = params_for(:result, expression: "d4", character_id: character.id)
      assert {:error, %Ecto.Changeset{}} = Rolls.create_result(params)
    end

    # [todo] Add tests for `Rolls.result_for_roll/1`.
  end

  test "get_roll_stats/2 returns the stats if there are results" do
    character = insert(:character)
    %Rolls.Roll{name: "Persuasion", expression: "1d20 + 2"}

    Enum.each([13, 2, 17], &insert(:result, name: "Persuasion", total: &1, character: character))

    assert Rolls.get_roll_stats(character, "Persuasion") == %{
             times_rolled: 3,
             lowest_roll: 2,
             highest_roll: 17,
             average_roll: 11
           }
  end

  test "get_roll_stats/2 returns empty stats if no results" do
    character = insert(:character)
    %Rolls.Roll{name: "Persuasion", expression: "1d20 + 2"}

    assert Rolls.get_roll_stats(character, "Persuasion") == %{
             times_rolled: 0,
             lowest_roll: nil,
             highest_roll: nil,
             average_roll: 0
           }
  end
end
