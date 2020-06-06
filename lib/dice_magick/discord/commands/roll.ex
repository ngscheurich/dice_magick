defmodule DiceMagick.Discord.Roll do
  @moduledoc """
  Handles the `!roll <EXPRESSION>` command.

  The input for this command can take two forms:

    1. A raw expression, e.g. `1d20 + 3 + 1d4`.
    2. A string matching one of the character's named rolls, e.g. "Acrobatics".

  When using option 2, a partial string may be provided, which DiceMagick use to
  select the first matching roll. Furthermore, the capitalization in the input
  string is discarded. For example, "wis" would match a roll named "Wisdom
  Check".

  ## Examples

  `!roll 1d20 + 1`
  > **Dust** rolls `1d20 + 1`…<br>
  > 🎲 Result: **14**

  `!roll sne`
  > **Saidri** rolls _Sneak Attack_ (`1d8 + 4 + 2d6`)…<br>
  > 🎲 Result: **21**

  `!roll foo`
  > 💀 I couldn’t find a roll matching “foo”.

  """

  alias DiceMagick.{Rolls, Discord, Characters, Dice}
  alias Characters.Character

  @behaviour Discord.Command

  @impl true
  def process([input], msg) do
    discord_uid = to_string(msg.author.id)
    channel_id = to_string(msg.channel_id)
    character = Characters.get_character_for_channel(discord_uid, channel_id)

    roll_for_character(character, input)
  end

  @spec roll_for_character(Character.t(), String.t()) :: Discord.Command.command_result()
  def roll_for_character(%Character{} = character, input) do
    with roll when not is_nil(roll) <- Rolls.get_roll_by_name(character, input),
         {:ok, result} <- Rolls.result_for_roll(roll) do
      {:ok,
       Discord.roll_message(character.name, roll.expression, result.outcome, roll_name: roll.name)}
    else
      _ ->
        # [todo] Should ad-hoc roll results be recorded as well? Probably?
        case Dice.roll(input) do
          {:ok, %{total: outcome}} -> {:ok, Discord.roll_message(character.name, input, outcome)}
          _ -> {:error, failure_message(input)}
        end
    end
  end

  def roll_for_character(_character, _input) do
    {:error,
     """
     :crystal_ball: You don’t have any characters in this channel.
     You can use `!create` to create one here, or `!transfer` to transfer one from another channel.
     """}
  end

  @spec failure_message(String.t()) :: String.t()
  defp failure_message(expression) do
    ":skull: No matching rolls were found, and `#{expression}` is not a valid dice expression."
  end
end
