defmodule DiceMagick.Repo.Migrations.AddExpressionToRolls do
  use Ecto.Migration

  def up do
    alter table(:rolls) do
      add :expression, :string
      remove :parts
    end

    execute "UPDATE rolls SET expression = '1d20' WHERE expression IS NULL"

    alter table(:rolls), do: modify(:expression, :string, null: false)
  end

  def down do
    alter table(:rolls) do
      remove :expression
      add :parts, :map
    end
  end
end
