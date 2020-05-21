defmodule Repo.Migrations.RemoveArchetypeAndStatsFromCharacters do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      remove :archetype
      remove :stats
    end

    execute "DROP TYPE character_archetypes;"
  end

  def down do
    execute "CREATE TYPE character_archetypes AS ENUM ('custom', 'dnd5e');"

    alter table(:characters) do
      add :archetype, :string, null: false, default: "custom"
      add :stats, :map, null: false, default: %{}
    end
  end
end
