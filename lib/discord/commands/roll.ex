defmodule Discord.Commands.Create do
  @behaviour Discord.Command

  alias Characters.Character

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
  def process([input], _msg) do
    discord_uid = to_string(msg.author.id)
    character = Characters.get_character_for_channel(discord_uid, msg.channel_id)

    with roll when not is_nil(roll) <- Rolls.get_roll_by_name(character, input),
         {:ok, result} <- Rolls.result_for_roll(roll) do
      success_message(character.name, roll.expression, result.outcome, roll_name: roll.name)
    else
      _ ->
        # [todo] The use of `try/rescue` here smells to me. Is there a better way to
        # handle direct user input?
        try do
          outcome = Rolls.roll(input)
          success_message(character.name, input, outcome)
        rescue
          failure_message(input)
        end
    end
  end

  @type opts() :: [{:roll_name, String.t()}]
  @spec success_message(String.t(), String.t(), Integer.t(), opts()) :: String.t()
  defp success_message(character_name, expression, outcome, opts \\ []) do
    info =
      case Keyword.get(opts, :roll_name) do
        nil -> "**#{character_name}** rolls `#{expression}`…"
        roll_name -> "**#{character_name}** rolls _#{roll_name}_ (`#{expression}`)…"
      end

    """
    #{info}
    :game-die: Result: **#{result}**
    """
  end

  @spec failure_message(String.t()) :: String.t()
  defp failure_message(expression) do
    ":skull: #{expression} is not a valid roll expression."
  end
end
