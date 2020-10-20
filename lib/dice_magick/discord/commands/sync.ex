defmodule DiceMagick.Discord.Commands.Sync do
  @moduledoc """
  Handles the `!sync` command.

  Updates the rolls for the character in the current channel. Sends a DM to the
  user informing them of success or failure.

  Raises `MatchError` if unsuccessful (see: DiceMagick.Characters.Worker.update_sync/1).

  ## Examples

  `!sync`
  >✨ Finished synchronizing Dust’s rolls.

  """

  alias DiceMagick.{Characters, Discord}

  @behaviour Discord.Command

  @impl true
  def execute(_params, msg) do
    discord_uid = to_string(msg.author.id)
    channel_id = to_string(msg.channel_id)
    character = Characters.get_character_for_channel(discord_uid, channel_id)

    Characters.Worker.update_sync(character.id)
    {:ok, ":sparkles: Finished synchronizing #{character.name}’s rolls."}
  end
end
