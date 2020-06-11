defmodule DiceMagick.Repo.Migrations.AddArchetypeToCharactersAgain do
  use Ecto.Migration

  def up do
    ArchetypeEnum.create_type()

    alter table(:characters) do
      add :archetype, ArchetypeEnum.type()
    end
  end

  def down do
    alter table(:characters) do
      remove :archetype
    end

    ArchetypeEnum.drop_type()
  end
end
