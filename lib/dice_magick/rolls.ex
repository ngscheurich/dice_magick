defmodule DiceMagick.Rolls do
  @moduledoc """
  Functions for working with `DiceMagick.Rolls.Roll`s and
  `DiceMagick.Rolls.Result`s.
  """

  import Ecto.Query

  alias DiceMagick.Rolls.{Result, Roll}
  alias DiceMagick.Characters
  alias Characters.Character
  alias DiceMagick.Repo

  @doc """
  Returns `DiceMagick.Dice.Result` of the given `DiceMagick.Rolls.Roll`'s
  `expression`.

  ## Options

    * `record?` - Asynchronously record the result as a `DiceMagick.Rolls.Result`?

  ## Examples

      iex> generate_result(%Roll{expression: "1d20"})
      %DiceMagick.Dice.Result{}

  """
  @spec generate_result(Roll.t(), [{:record?, boolean}]) :: DiceMagick.Dice.Result.t()
  def generate_result(%Roll{expression: expression} = roll, opts \\ []) do
    result = DiceMagick.Dice.roll!(expression)
    record? = Keyword.get(opts, :record?, true)

    if Mix.env() != :test && record? do
      Task.Supervisor.start_child(
        DiceMagick.DBTaskSupervisor,
        fn ->
          roll
          |> Map.from_struct()
          |> Map.put(:total, result.total)
          |> Map.put(:faces, result.faces)
          |> create_result()
        end,
        restart: :transient
      )
    end

    result
  end

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
  Gets the `DiceMagick.Rolls.Roll` whose name starts with the given `roll_name`.

  Capitalization in the `roll_name` string is ignored, i.e. "wis" would match a
  `Roll` named "Wisdom Check".

  Returns `nil` if no result is found.

  ## Examples

      iex> get_roll_by_name(character, "sne")
      %Roll{name: "Sneak Attack"}

      iex> get_roll_by_name(character, "foo")
      nil

  """
  @spec get_roll_by_name(Character.t(), String.t()) :: Roll.t() | nil
  def get_roll_by_name(%Character{id: character_id}, roll_name) do
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
  def roll(input) do
    %{total: total} = DiceMagick.Dice.roll!(input)
    total
  end

  @doc """
  [todo] Write documentation.
  """
  @spec get_roll_stats(Character.t(), String.t()) :: map
  def get_roll_stats(%Character{id: character_id}, roll_name) do
    # [todo] Should we group results on character ID, name, _and_ expression?
    query =
      from r in Result,
        where: r.character_id == ^character_id,
        where: r.name == ^roll_name

    totals =
      query
      |> Repo.all()
      |> Enum.map(& &1.total)
      |> Enum.sort()

    count = Enum.count(totals)

    %{
      times_rolled: count,
      lowest_roll: List.first(totals),
      highest_roll: List.last(totals),
      average_roll:
        case Enum.sum(totals) do
          0 -> 0
          sum -> round(sum / count)
        end
    }
  end
end
