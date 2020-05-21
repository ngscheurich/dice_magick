defmodule Repo.Migrations.AddArchetypeToCharacters do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE character_archetypes AS ENUM ('custom', 'dnd5e');"

    alter table(:characters) do
      add :archetype, :string, null: false, default: "custom"
    end
  end

  def down do
    alter table(:characters) do
      remove :archetype
    end

    execute "DROP TYPE character_archetypes;"
  end
end
