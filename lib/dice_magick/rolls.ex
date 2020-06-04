defmodule DiceMagick.Rolls do
  @moduledoc """
  Functions for working with `DiceMagick.Rolls.Roll`s and
  `DiceMagick.Rolls.Result`s.
  """

  alias DiceMagick.Rolls.{Result, Roll}
  alias DiceMagick.Characters
  alias DiceMagick.Repo

  @doc """
  Creates a `DiceMagick.Rolls.Result`.

  ## Examples

      iex> create_result(%{field: value})
      {:ok, %Result{}}

      iex> create_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_result(map) :: {:ok, Result.t()} | {:error, Ecto.Changeset.t()}
  def create_result(attrs \\ %{}) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets the result of the given `DiceMagick.Rolls.Roll`'s `expression`. Records
  the result as a `DiceMagick.Rolls.Result`.

  ## Examples

      iex> result_for_roll(%Roll{expression: "1d20"})
      12

      iex> result_for_roll(%Roll{expression: "d20"})
      {:error, {:token_parsing_failed, ['syntax error before: ', ['"d"']]}}

  """
  @spec result_for_roll(Roll.t()) :: {:ok, Result.t()} | {:error, Ecto.Changeset.t()}
  def result_for_roll(%Roll{expression: expression} = roll) do
    outcome = ExDiceRoller.roll(expression)

    # [todo] Make DB work asynchronous?
    roll
    |> Map.from_struct()
    |> Map.put(:outcome, outcome)
    |> create_result()
  end

  @doc """
  Gets the `DiceMagick.Rolls.Roll` whose name starts with the given `roll_name`.

  Capitalization in the `roll_name` string is ignored, i.e. "wis" would match a
  `Roll` named "Wisdom Check".

  Returns `nil` if no result is found.

  ## Examples

      iex> get_roll_starting_with(character, "sne")
      %Roll{name: "Sneak Attack"}

      iex> get_roll_starting_with(character, "foo")
      nil

  """
  @spec get_roll_by_name(Characters.Character.t(), String.t()) :: Roll.t() | nil
  def get_roll_by_name(%Characters.Character{id: character_id}, roll_name) do
    character_id
    |> Characters.Worker.state()
    |> Map.get(:rolls)
    |> Enum.filter(&matches_roll_name?(&1, roll_name))
    |> List.first()
  end

  @spec matches_roll_name?(Roll.t(), String.t()) :: boolean
  defp matches_roll_name?(%Roll{name: name}, roll_name) do
    name = String.downcase(name)
    str = String.downcase(roll_name)
    String.starts_with?(name, str)
  end

  @doc """
  # Dice roller abstration layer.
  # [todo] Write documentation.
  # [todo] Should this be in its own module?
  """
  @spec roll(String.t()) :: Integer.t() | {:error, any()}
  def roll(expression), do: ExDiceRoller.roll(expression)
end
