defmodule DiceMagick.Repo.Migrations.AddSourceDataToCharacters do
  use Ecto.Migration

  def up do
    SourceTypeEnum.create_type()

    alter table(:characters) do
      add :source_type, SourceTypeEnum.type()
      add :source_params, :map
    end
  end

  def down do
    alter table(:characters) do
      remove :source_type
      remove :source_params
    end

    SourceTypeEnum.drop_type()
  end
end
