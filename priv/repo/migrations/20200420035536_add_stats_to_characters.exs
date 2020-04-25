defmodule DiceMagick.Repo.Migrations.AddStatsToCharacters do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :stats, :map, null: false, default: %{}
    end
  end
end
