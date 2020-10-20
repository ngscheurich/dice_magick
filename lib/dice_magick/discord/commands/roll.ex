defmodule DiceMagick.Discord.Commands.Roll do
  @moduledoc """
  Handles the `!roll <EXPRESSION>` command.

  The input for this command can take two forms:

    1. A raw expression, e.g. `1d20 + 3 + 1d4`.
    2. A string matching one of the character's named rolls, e.g. "Acrobatics".

  When using option 2, a partial string may be provided, which DiceMagick uses
  to select the first matching roll. Furthermore, the capitalization in the
  input string is discarded. For example, "wis" would match a roll named
  "Wisdom Check".

  ## Examples

  `!roll 1d20 + 1`
  > **Dust** rolls `1d20 + 1`…
  > 🎲 Result: **14** (`[13]`)

  `!roll sne`
  > **Saidri** rolls _Sneak Attack_ (`1d8 + 4 + 2d6`)…
  > 🎲 Result: **17** (`[3, 4, 6]`)

  `!roll foo`
  > 💀 I couldn’t find a roll matching “foo”.

  """

  alias DiceMagick.{Rolls, Discord, Characters}
  alias Characters.Character

  @behaviour Discord.Command

  @impl true
  def execute([input], msg) do
    discord_uid = to_string(msg.author.id)
    channel_id = to_string(msg.channel_id)
    character = Characters.get_character_for_channel(discord_uid, channel_id)

    roll_for_character(character, input)
  end

  @spec roll_for_character(Character.t(), String.t()) :: Discord.Command.command_result()
  defp roll_for_character(%Character{} = character, input) do
    case Rolls.get_roll_by_name(character, input) do
      nil ->
        if DiceMagick.Dice.valid_expression?(input) do
          roll = %{expression: input, character_id: character.id}
          {:ok, success_message(character.name, roll)}
        else
          {:error, failure_message(input)}
        end

      roll ->
        {:ok, success_message(character.name, roll, roll_name: roll.name)}
    end
  end

  defp roll_for_character(nil, _input) do
    {:error,
     """
     :crystal_ball: You don’t have any characters in this channel.
     You can use `!create` to create one here, or `!transfer` to transfer one from another channel.
     """}
  end

  @spec success_message(String.t(), Rolls.Roll.t(), keyword()) :: String.t()
  defp success_message(name, roll, opts \\ []) do
    result = Rolls.generate_result(roll)
    Discord.roll_message(name, result, opts)
  end

  @spec failure_message(String.t()) :: String.t()
  defp failure_message(expression) do
    ":skull: No matching rolls were found, and `#{expression}` is not a valid dice expression."
  end
end
