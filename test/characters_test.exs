defmodule CharactersTest do
  use DataCase

  alias Characters

  describe "characters" do
    alias Characters.Character

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
                 discord_channel_id: "1234567890",
                 user_id: user_id
               })

      assert character.name == "Baldur"
      assert character.source_type == :test
      assert character.source_params == %{"test" => true}
      assert character.discord_channel_id == "1234567890"
      assert character.user_id == user_id
      refute character.id |> Characters.Worker.name() |> GenServer.whereis() |> is_nil
    end

    test "create_character/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Characters.create_character(%{})
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
      assert {:error, %Ecto.Changeset{}} = Characters.update_character(character, %{name: ""})

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

    test "get_character_for_channel/2 returns the character if one exists" do
      user = insert(:user, discord_uid: "1")
      character = insert(:character, user: user, discord_channel_id: "2")
      assert Characters.get_character_for_channel("1", "2").id == character.id
    end

    test "get_character_for_channel/2 returns nil character does not exist" do
      assert Characters.get_character_for_channel("1", "2") |> is_nil()
    end

    test "character discord_channel_ids must be unique per user" do
      user = insert(:user)
      insert(:character, discord_channel_id: "1", user: user)

      assert {:error, %Ecto.Changeset{}} =
               Characters.create_character(%{params_for(:character) | discord_channel_id: "1"})
    end

    test "character names must be unique per user" do
      user = insert(:user)
      insert(:character, name: "Dust", user: user)

      assert {:error, %Ecto.Changeset{}} =
               Characters.create_character(%{params_for(:character) | name: "Dust"})
    end
  end
end
