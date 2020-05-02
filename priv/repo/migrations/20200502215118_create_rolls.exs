defmodule DiceMagick.Repo.Migrations.CreateRolls do
  use Ecto.Migration

  def change do
    create table(:rolls, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :parts, :map, null: false
      add :character_id, references(:users, type: :binary_id), null: false, on_delete: :delete_all

      timestamps()
    end

    create index(:rolls, :character_id)
    create unique_index(:rolls, [:character_id, :name])
  end
end
