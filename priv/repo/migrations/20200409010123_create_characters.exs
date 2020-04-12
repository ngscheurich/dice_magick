defmodule DiceMagick.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :user_id, references(:users, type: :binary_id), null: false, on_delete: :delete_all

      timestamps()
    end

    create index(:characters, :user_id)
  end
end
