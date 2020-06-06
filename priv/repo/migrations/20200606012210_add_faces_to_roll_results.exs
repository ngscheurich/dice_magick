defmodule DiceMagick.Repo.Migrations.AddFacesToRollResults do
  use Ecto.Migration

  def change do
    alter table(:roll_results) do
      add :faces, {:array, :integer}, default: []
    end
  end
end
