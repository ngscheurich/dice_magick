defmodule Repo.Migrations.MakeUserCharacterNamesUnique do
  use Ecto.Migration

  def change do
    create unique_index(:characters, [:name, :user_id])
  end
end
