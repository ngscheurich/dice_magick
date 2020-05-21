defmodule Repo.Migrations.AddAdditionalColumnsToRolls do
  use Ecto.Migration

  def change do
    alter table(:rolls) do
      add :favorite, :boolean, null: false, default: false
      add :metadata, :map
    end
  end
end
