defmodule DiceMagick.Repo.Migrations.AddColorToCharacters do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      add :color, :string, default: "#ca4548"
    end

    execute "UPDATE characters SET color = '#ca4548'"

    alter table(:characters) do
      modify :color, :string, null: false
    end
  end
end
