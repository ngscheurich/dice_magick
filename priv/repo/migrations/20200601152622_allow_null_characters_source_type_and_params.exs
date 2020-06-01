defmodule Repo.Migrations.AllowNullCharactersSourceTypeAndParams do
  use Ecto.Migration

  def up do
    alter table(:characters) do
      modify :source_type, SourceTypeEnum.type(), null: true
      modify :source_params, :map, null: true
    end
  end

  def down do
    alter table(:characters) do
      modify :source_type, SourceTypeEnum.type(), null: false
      modify :source_params, :map, null: false
    end
  end
end
