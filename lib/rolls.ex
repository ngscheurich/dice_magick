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

  @doc """
  Gets the result of the given `Rolls.Roll`'s `expression`. Asynchonously records the
  result as a `Rolls.Result`.

  ## Examples

      iex> result_for_roll(%Roll{expression: "1d20"})
      12

      iex> result_for_roll(%Roll{expression: "d20"})
      {:error, {:token_parsing_failed, ['syntax error before: ', ['"d"']]}}

  """
  @spec result_for_roll(Roll.t()) :: integer() | {:error, term()}
  def result_for_roll(%Roll{expression: expression} = roll) do
    outcome = ExDiceRoller.roll(expression)

    roll
    |> Map.from_struct()
    |> Map.put(:outcome, outcome)
    |> create_result()
  end
end
