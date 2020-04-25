defmodule DiceMagick.Repo.Migrations.AddArchetypeToCharacters do
  use Ecto.Migration

  def up do
    CharacterArchetypeEnum.create_type()

    alter table(:characters) do
      add :archetype, CharacterArchetypeEnum.type(), null: false, default: "custom"
    end
  end

  def down do
    alter table(:characters) do
      remove :archetype
    end

    CharacterArchetypeEnum.drop_type()
  end
end
