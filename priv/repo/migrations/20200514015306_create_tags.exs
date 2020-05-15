defmodule DiceMagick.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false

      add :character_id, references(:characters, type: :binary_id),
        null: false,
        on_delete: :delete_all

      unique_index(:tags, [:name, :character])

      timestamps()
    end

    create table(:roll_tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :roll_id, references(:rolls, type: :binary_id), null: false, on_delete: :delete_all
      add :tag_id, references(:tags, type: :binary_id), null: false, on_delete: :delete_all

      unique_index(:roll_tags, [:roll_id, :tag_id])

      timestamps()
    end
  end
end
