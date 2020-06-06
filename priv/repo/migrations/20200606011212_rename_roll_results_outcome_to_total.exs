defmodule DiceMagick.Repo.Migrations.RenameRollResultsOutcomeToTotal do
  use Ecto.Migration

  def change do
    rename table(:roll_results), :outcome, to: :total
  end
end
