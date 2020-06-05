defmodule DiceMagick.Dice do
  @moduledoc """
  Functions for determinig the outcome of dice rolling expressions.
  """

  defmodule Outcome do
    @moduledoc """
    Used to encapsulate dice rolling outcomes. Has two fields:

      * `total` - The sum of all die rolls and modifiers
      * `rolls` - A list of the outcome of every die rolled

    """
    @type t :: %__MODULE__{}
    defstruct [:total, rolls: []]
  end

  @doc """
  Parses and rolls the given `input`, then returns the resulting
  `%DiceMagick.Dice.Outcome{}`.

  The `input` should be comprised of a series of _determinate_ and
  _indeterminate_ expressions, with the former being simple integers and the
  latter being strings representing a number of dice with _n_ sides, e.g.
  "1d20", 8d4".

  These expressions should be joined together with `+` or `-` symbols,
  representing whether the result of the expression should be added or
  subtracted to the total result.

  ## Examples

      iex> roll("1d20 + 3")
      %Outcome{total: 15, rolls: [12])

      iex> roll("1d20 + 1 + 3d4 + 2 - 15")
      %Outcome{total: 5, rolls: [8, 3, 2, 4])

  """
  @spec roll(String.t()) :: Outcome.t()
  def roll(input) do
    input = process_input(input)
    parsed = get_dice_parts(input) ++ get_mod_parts(input)

    Enum.reduce(parsed, %Outcome{total: 0}, fn part, outcome ->
      case part do
        {fun, _, val} ->
          %Outcome{total: apply(Kernel, fun, [outcome.total, val]), rolls: outcome.rolls ++ [val]}

        {fun, val} ->
          %Outcome{outcome | total: apply(Kernel, fun, [outcome.total, val])}
      end
    end)
  end

  @spec process_input(String.t()) :: String.t()
  def process_input(input) do
    input = String.replace(input, ~r/\s+/, "")
    <<head::binary-size(1)>> <> _ = input

    case head do
      "-" -> input
      _ -> "+" <> input
    end
  end

  @spec get_dice_parts(String.t()) :: [{atom, integer, integer}]
  def get_dice_parts(input) do
    matches = Regex.scan(~r/([+-])(\d+d\d+)/, input, capture: :all_but_first)

    Enum.flat_map(matches, fn [operator, dice] ->
      [num, sides] = String.split(dice, "d")
      {num, _} = Integer.parse(num)
      Enum.map(1..num, fn _ -> dice_part_result(sides, operator) end)
    end)
  end

  @spec dice_part_result(String.t(), String.t()) :: {atom, integer, integer}
  defp dice_part_result(sides, operator) do
    {sides, _} = Integer.parse(sides)
    outcome = Enum.random(1..sides)
    operator = get_operator(operator)
    {operator, sides, outcome}
  end

  @spec get_mod_parts(String.t()) :: [{atom, integer}]
  defp get_mod_parts(input) do
    matches = Regex.scan(~r/([+-])(\d+)(?!d)/, input, capture: :all_but_first)

    Enum.map(matches, fn [operator, mod] ->
      operator = get_operator(operator)
      {mod, _} = Integer.parse(mod)
      {operator, mod}
    end)
  end

  @spec get_operator(String.t()) :: atom
  defp get_operator(""), do: :+
  defp get_operator(str), do: String.to_atom(str)
end
