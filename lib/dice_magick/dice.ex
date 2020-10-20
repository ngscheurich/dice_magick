defmodule DiceMagick.Dice do
  @moduledoc """
  Functions for determining the result of dice expressions.
  """

  alias __MODULE__.Result
  alias DiceMagick.Rolls

  @doc """
  Parses and evaluates the given `expression`, then returns the
  `DiceMagick.Dice.Result`.

  If the `expression` is invalid, returns an error.

  The `expression` should be comprised of a series of _determinate_ and
  _indeterminate_ sub-expressions, with the former being simple integers and
  the latter being strings representing a number of dice with _n_ sides, e.g.
  "1d20", 8d4".

  These sub-expressions should be joined together with `+` or `-` symbols,
  representing whether the outcome of each should be added or subtracted to the
  total result.

  ## Examples

      iex> evaluate("1d20 + 3")
      {:ok, %DiceMagick.Dice.Result{total: 15, faces: [12])}

      iex> evaluate("1d20 + 1 + 3d4 + 2 - 15")
      {:ok, %DiceMagick.Dice.Result{total: 5, faces: [8, 3, 2, 4])}

      iex> evaluate("1d12 - x")
      {:error, :invalid_expression}

  """
  @spec evaluate(String.t()) :: {:ok, Result.t()} | {:error, :invalid_expression}
  def evaluate(expression) do
    if valid_expression?(expression) do
      {:ok, process_expression(expression)}
    else
      {:error, :invalid_expression}
    end
  end

  @doc """
  Similar to `evaluate/1`, but raises `ArgumentError` if `expression` is
  invalid.

  ## Examples

      iex> evaluate!("1d20 + 3")
      %Result{total: 15, faces: [12])}

      iex> evaluate!("1d12 - x")
      ** (ArgumentError) argument error

  """
  @spec evaluate!(String.t()) :: Result.t()
  def evaluate!(expression) do
    if valid_expression?(expression) do
      process_expression(expression)
    else
      raise ArgumentError
    end
  end

  @spec process_expression(String.t()) :: Result.t()
  defp process_expression(expression) do
    input = process_input(expression)
    parsed = get_dice_parts(input) ++ get_mod_parts(input)

    Enum.reduce(parsed, %Result{expression: expression, total: 0}, fn part, result ->
      case part do
        {fun, _, val} ->
          total = apply(Kernel, fun, [result.total, val])
          %Result{result | total: total, faces: result.faces ++ [val]}

        {fun, val} ->
          total = apply(Kernel, fun, [result.total, val])
          %Result{result | total: total}
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
    result = Enum.random(1..sides)
    operator = get_operator(operator)
    {operator, sides, result}
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

  @doc """
  Converts the given `DiceMagick.Dice.Result` into a `DiceMagick.Rolls.Result`
  based on the given `DiceMagick.Rolls.Roll`.

  Raises `ArgumentError` if `expression`s do not match.

  ## Examples

  iex> result = %DiceMagick.Dice.Result{total: 22, faces: [18, 4]}
  ...> roll = %DiceMagick.Rolls.Roll{name: "Stealth Check"}
  ...> to_roll_result(result, roll)
  %DiceMagick.Rolls.Result{name: "Stealth Check", total: 22, faces: [18, 4]}

  iex> result = %DiceMagick.Dice.Result{expression: "1d20"}
  ...> roll = %DiceMagick.Rolls.Roll{expression: "1d10"}
  ...> to_roll_result(result, roll)
  ** (ArgumentError) argument error

  """
  @spec to_roll_result(Result.t(), Rolls.Roll.t()) :: Rolls.Result.t()
  def to_roll_result(%Result{expression: ex} = result, %Rolls.Roll{expression: ey} = roll)
      when ex == ey do
    roll
    |> Map.from_struct()
    |> Map.put(:total, result.total)
    |> Map.put(:faces, result.faces)
    |> struct!(Rolls.Result)
  end

  def to_roll_result(_, _), do: raise(ArgumentError)
end
