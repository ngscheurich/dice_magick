defmodule DiceMagick.Repo.Migrations.AddSourceDataToCharacters do
  use Ecto.Migration

  def up do
    SourceTypeEnum.create_type()

    alter table(:characters) do
      add :source_type, SourceTypeEnum.type()
      add :source_params, :map
    end

    execute """
    UPDATE characters
    SET source_type = 'test', source_params = '{"test": true}'
    WHERE source_type IS NULL OR source_params IS NULL
    """

    alter table(:characters) do
      modify :source_type, SourceTypeEnum.type(), null: false
      modify :source_params, :map, null: false
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
