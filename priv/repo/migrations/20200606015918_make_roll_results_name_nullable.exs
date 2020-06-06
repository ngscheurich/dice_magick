defmodule DiceMagick.Repo.Migrations.MakeRollResultsNameNullable do
  use Ecto.Migration

  def up do
    alter table(:roll_results), do: modify(:name, :string, null: true)
  end

  def down do
    alter table(:roll_results), do: modify(:name, :string, null: false)
  end
end
