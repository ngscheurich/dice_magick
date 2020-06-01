defmodule Repo.Migrations.AddDiscordChannelIdToCharacters do
  use Ecto.Migration

  @proto_channel_id "696164779492114485"

  def change do
    alter table(:characters), do: add(:discord_channel_id, :string)

    execute(
      "UPDATE characters SET discord_channel_id = '#{@proto_channel_id}' WHERE discord_channel_id IS NULL"
    )

    alter table(:characters), do: modify(:discord_channel_id, :string, null: false)

    create unique_index(:characters, [:discord_channel_id, :user_id])
  end
end
