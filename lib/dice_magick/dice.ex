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
  Parses and rolls the given `expression`, then returns the resulting
  `%DiceMagick.Dice.Outcome{}`.

  If the `expression` is invalid, returns an error.

  The `expression` should be comprised of a series of _determinate_ and
  _indeterminate_ expressions, with the former being simple integers and the
  latter being strings representing a number of dice with _n_ sides, e.g.
  "1d20", 8d4".

  These expressions should be joined together with `+` or `-` symbols,
  representing whether the result of the expression should be added or
  subtracted to the total result.

  ## Examples

      iex> roll("1d20 + 3")
      {:ok, %Outcome{total: 15, rolls: [12])}

      iex> roll("1d20 + 1 + 3d4 + 2 - 15")
      {:ok, %Outcome{total: 5, rolls: [8, 3, 2, 4])}

      iex> roll("1d12 - x")
      {:error, :invalid_expression}

  """
  @spec roll(String.t()) :: {:ok, Outcome.t()} | {:error, :invalid_expression}
  def roll(expression) do
    if valid_expression?(expression) do
      {:ok, process_expression(expression)}
    else
      {:error, :invalid_expression}
    end
  end

  @doc """
  Similar to `roll/1`, but raises `ArgumentError` if an invalid `expression` is
  provided.

  ## Examples

      iex> roll!("1d20 + 3")
      %Outcome{total: 15, rolls: [12])}

      iex> roll!("1d12 - x")
      ** (ArgumentError) argument error

  """
  def roll!(expression) do
    if valid_expression?(expression) do
      process_expression(expression)
    else
      raise ArgumentError
    end
  end

  @spec process_expression(String.t()) :: Outcome.t()
  defp process_expression(expression) do
    input = process_input(expression)
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
  defp process_input(input) do
    input = String.replace(input, ~r/\s+/, "")
    <<head::binary-size(1)>> <> _ = input

    case head do
      "-" -> input
      _ -> "+" <> input
    end
  end

  @spec get_dice_parts(String.t()) :: [{atom, integer, integer}]
  defp get_dice_parts(input) do
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

  @doc """
  Checks whether the given `expression` is valid.

  ## Examples

      iex> valid_expression?("1d20 + 3 - 3d4")
      true

      iex> valid_expression?("3 + 1d12 + d6")
      false

  """
  def valid_expression?(expression) do
    expression
    |> String.replace(~r/\s+/, "")
    |> String.split(~r/[+-]/)
    |> Enum.filter(&(!valid_part?(&1)))
    |> Enum.count() == 0
  end

  @spec valid_part?(String.t()) :: boolean
  defp valid_part?(part) do
    case String.split(part, "d") do
      [_, _] = res ->
        res
        |> Enum.reduce([], &(&2 ++ [Integer.parse(&1)]))
        |> Enum.filter(&(&1 == :error))
        |> Enum.count() == 0

      [res] ->
        with {_, rem} when rem == "" <- Integer.parse(res) do
          true
        else
          _ -> false
        end
    end
  end
end
