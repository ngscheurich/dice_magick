defmodule RollsTest do
  use DataCase

  alias Rolls

  describe "results" do
    alias Rolls.{Result, Roll}

    test "create_result/1 with valid data creates a roll result" do
      character = insert(:character)

      assert {:ok, %Result{} = result} =
               Rolls.create_result(%{
                 name: "Sneak Attack",
                 expression: "1d20 + 4 + 1d6",
                 favorite: true,
                 tags: ["combat", "dex"],
                 outcome: 28,
                 character_id: character.id
               })

      assert result.name == "Sneak Attack"
      assert result.expression == "1d20 + 4 + 1d6"
      assert result.favorite == true
      assert result.tags == ["combat", "dex"]
      assert result.outcome == 28
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
end
