defmodule Repo.Migrations.CreateRollResults do
  use Ecto.Migration

  def change do
    create table(:roll_results, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :expression, :string, null: false
      add :metadata, :map
      add :favorite, :boolean, null: false, default: false
      add :tags, {:array, :string}, null: false, default: []
      add :outcome, :integer, null: false

      add :character_id, references(:characters, type: :binary_id),
        null: false,
        on_delete: :delete_all

      timestamps(updated_at: false)
    end

    create index(:roll_results, :character_id)
  end
end
