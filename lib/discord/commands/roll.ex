defmodule Discord.Commands.Roll do
  @behaviour Discord.Command

  @doc """
  Handles the `!dm roll <EXPRESSION>` command.

  The input for this command can take two forms:

    1. A raw expression, e.g. `1d20 + 3 + 1d4`.
    2. A string matching one of the character's named rolls, e.g. "Acrobatics".

  When using option 2, a partial string may be provided, which DiceMagick use
  to select the first matching roll. Furthermore, the capitalization and
  whitespace in the input string is discarded. For example, "wisch" would match
  a roll named "Wisdom Check".

  ## Examples

      !dm roll 1d20 + 1
      **Dust** rolls `1d20 + 1`…
      :game-die: Result: **14**

      !dm roll sne
      **Saidri** rolls _Sneak Attack_ (`1d8 + 4 + 2d6`)…
      :game-die: Result: **21**

      !dm roll foo
      :skull: I couldn’t find a roll matching “foo”.

  """
  @impl true
  def process([input], msg) do
    discord_uid = to_string(msg.author.id)
    channel_id = to_string(msg.channel_id)
    character = Characters.get_character_for_channel(discord_uid, channel_id)

    with roll when not is_nil(roll) <- Rolls.get_roll_by_name(character, input),
         {:ok, result} <- Rolls.result_for_roll(roll) do
      Discord.roll_message(character.name, roll.expression, result.outcome, roll_name: roll.name)
    else
      _ ->
        # [todo] The use of `try/rescue` here smells to me. Is there a better way to
        # handle direct user input?
        try do
          outcome = Rolls.roll(input)
          Discord.roll_message(character.name, input, outcome)
        rescue
          _ -> failure_message(input)
        end
    end
  end

  @spec failure_message(String.t()) :: String.t()
  defp failure_message(expression) do
    ":skull: #{expression} is not a valid roll expression."
  end
end
