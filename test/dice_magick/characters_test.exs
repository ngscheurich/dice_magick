defmodule DiceMagick.CharactersTest do
  use DiceMagick.DataCase

  alias DiceMagick.Characters

  describe "characters" do
    alias DiceMagick.Characters.Character

    @invalid_attrs %{name: nil, source_type: nil, source_params: nil, user_id: nil}

    test "list_characters_for_user/1 returns all characters for user" do
      user = insert(:user)
      character = insert(:character, user: user)
      assert_ids_match(Characters.list_characters_for_user(user), [character])
    end

    test "get_character!/1 returns the character with given id" do
      character = insert(:character)
      assert Characters.get_character!(character.id).id == character.id
    end

    test "create_character/1 with valid data creates a character" do
      %{id: user_id} = insert(:user)

      assert {:ok, %Character{} = character} =
               Characters.create_character(%{
                 name: "Baldur",
                 source_type: :test,
                 source_params: %{"test" => true},
                 user_id: user_id
               })

      assert character.name == "Baldur"
      assert character.user_id == user_id
    end

    test "create_character/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Characters.create_character(@invalid_attrs)
    end

    test "update_character/2 with valid data updates the character" do
      %{id: user_id} = insert(:user)
      character = insert(:character)

      assert {:ok, %Character{} = character} =
               Characters.update_character(character, %{name: "Ophelia", user_id: user_id})

      assert character.name == "Ophelia"
      assert character.user_id == user_id
    end

    test "update_character/2 with invalid data returns error changeset" do
      user = insert(:user)
      character = insert(:character, name: "Baldur", user: user)
      assert {:error, %Ecto.Changeset{}} = Characters.update_character(character, @invalid_attrs)

      character = Characters.get_character!(character.id)
      assert character.name == "Baldur"
      assert character.user_id == user.id
    end

    test "delete_character/1 deletes the character" do
      character = insert(:character)
      assert {:ok, %Character{}} = Characters.delete_character(character)
      assert_raise Ecto.NoResultsError, fn -> Characters.get_character!(character.id) end
    end

    test "change_character/1 returns a character changeset" do
      character = insert(:character)
      assert %Ecto.Changeset{} = Characters.change_character(character)
    end
  end
end
