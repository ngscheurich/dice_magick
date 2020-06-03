defmodule Rolls do
  @moduledoc """
  Functions for working with `Rolls.Roll`s and `Rolls.Result`s.
  """

  alias Rolls.{Result, Roll}
  alias Repo

  @doc """
  Creates a `Rolls.Result`.

  ## Examples

      iex> create_result(%{field: value})
      {:ok, %Result{}}

      iex> create_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_result(map()) :: {:ok, Result.t()} | {:error, Ecto.Changeset.t()}
  def create_result(attrs \\ %{}) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
  end

  # [todo] Make DB work asynchronous?
  @doc """
  Gets the result of the given `Rolls.Roll`'s `expression`. Records the result as a
  `Rolls.Result`.

  ## Examples

      iex> result_for_roll(%Roll{expression: "1d20"})
      12

      iex> result_for_roll(%Roll{expression: "d20"})
      {:error, {:token_parsing_failed, ['syntax error before: ', ['"d"']]}}

  """
  @spec result_for_roll(Roll.t()) :: {:ok, Result.t()} | {:error, Ecto.Changeset.t()}
  def result_for_roll(%Roll{expression: expression} = roll) do
    outcome = ExDiceRoller.roll(expression)

    roll
    |> Map.from_struct()
    |> Map.put(:outcome, outcome)
    |> create_result()
  end

  @doc """
  Gets the `Rolls.Roll` whose name starts with the given `roll_name`.

  Capitalization and whitespace in the `roll_name` string is discarded, i.e. "wisch" would
  match a `Roll` named "Wisdom Check".

  Returns `nil` if no result is found.

  ## Examples

      iex> get_roll_starting_with(character, "sne")
      %Roll{name: "Sneak Attack"}

      iex> get_roll_starting_with(character, "foo")
      nil

  """
  def get_roll_by_name(%Characters.Character{id: character_id}, roll_name) do
    Characters.Supervisor.ensure_started(character_id)

    character_id
    |> Characters.Worker.state()
    |> Map.get(:rolls)
    |> Enum.filter(fn roll ->
      name = String.downcase(roll.name)
      input = String.downcase(roll_name)
      String.starts_with?(name, input)
    end)
    |> List.first()
  end

  @doc """
  # [todo] Write documentation.
  # [todo] Should this be in its own module?
  # Dice roller abstration layer.
  """
  @spec roll(String.t()) :: Integer.t() | {:error, any()}
  def roll(expression), do: ExDiceRoller.roll(expression)
end
