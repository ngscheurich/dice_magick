defmodule DiceMagick.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :nickname, :string, null: false
      add :image, :string
      add :discord_uid, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:discord_uid])
  end
end
