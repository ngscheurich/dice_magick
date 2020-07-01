defmodule DiceMagick.Repo.Migrations.AddTintagel5eSourceTypeEnum do
  use Ecto.Migration

  def up do
    execute "ALTER TYPE source_type RENAME TO source_type_old;"
    execute "CREATE TYPE source_type AS ENUM('test', 'google_sheets', 'tintagel_5e');"

    execute """
    ALTER TABLE characters ALTER COLUMN source_type
      TYPE source_type USING source_type::text::source_type;
    """

    execute "DROP TYPE source_type_old;"
  end

  def down do
    execute "ALTER TYPE source_type RENAME TO source_type_old;"
    execute "CREATE TYPE source_type AS ENUM('test', 'google_sheets');"

    execute """
    ALTER TABLE characters ALTER COLUMN source_type
      TYPE source_type USING source_type::text::source_type;
    """

    execute "DROP TYPE source_type_old;"
  end
end
