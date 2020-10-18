defmodule DiceMagickWeb.CharacterLive.Helpers do
  @moduledoc """
  Helper functions for the `DiceMagickWeb.CharacterLive` module.
  """

  alias DiceMagick.Rolls
  alias Rolls.Roll
  alias Rolls.Characters.Character
  alias DiceMagickWeb.CharacterLive.State
  alias DiceMagick.Discord

  @doc """
  Creates two sets of `DiceMagick.Rolls.Roll`s using the given `rolls`, one
  containing all of the `Roll`s marked as `favorite`.

  Both sets are returned as lists sorted by `name`.

  ## Examples

      iex> group_rolls_by_favorites(rolls)
      {[%Roll{}, ...], [%Roll{}, ...]}

  """
  @spec group_rolls_by_favorites([Roll.t()]) :: {[Roll.t()], [Roll.t()]}
  def group_rolls_by_favorites(rolls) do
    rolls
    |> sort_rolls()
    |> Enum.reduce({[], []}, fn cur, {pinned, rest} ->
      case cur.favorite do
        true -> {pinned ++ [cur], rest ++ [cur]}
        false -> {pinned, rest ++ [cur]}
      end
    end)
  end

  @doc """
  Creates two sets of `DiceMagick.Rolls.Roll`s using the given `rolls`, one
  containing all of the `Roll`s tagged with one of the given `tags`.

  Both sets are returned as lists sorted by `name`.

  ## Examples

      iex> group_rolls_by_tags(rolls)
      {[%Roll{}, ...], [%Roll{}, ...]}

  """
  @spec group_rolls_by_tags([Roll.t()], [String.t()]) :: {[Roll.t()], [Roll.t()]}
  def group_rolls_by_tags(rolls, tags) do
    case Enum.count(tags) do
      0 ->
        group_rolls_by_favorites(rolls)

      _ ->
        rolls
        |> sort_rolls()
        |> Enum.reduce({[], []}, fn cur, {pinned, rest} ->
          if Enum.any?(cur.tags, &Enum.member?(tags, &1)) do
            {pinned ++ [cur], rest}
          else
            {pinned, rest ++ [cur]}
          end
        end)
    end
  end

  @spec sort_rolls([Roll.t()]) :: [Roll.t()]
  defp sort_rolls(rolls), do: Enum.sort_by(rolls, &String.first(&1.name))

  @doc """
  Returns a relatively-formatted representation of the given `datetime`.

  ## Examples

      iex> format_synced_at(datetime)
      "2 minutes ago"

      iex> format_synced_at(datetime)
      "About a month ago"

  """
  @spec format_synced_at(DateTime.t()) :: String.t()
  def format_synced_at(datetime) do
    case Timex.Format.DateTime.Formatters.Relative.format!(datetime, "{relative}") do
      "now" -> "Just now"
      str -> str
    end
  end

  @type roll_opts() :: [times: integer(), comparison_fun: String.t()]

  @doc """
  Generates `DiceMagick.Rolls.Result`s for the `DiceMagickWeb.Rolls.Roll` named
  `name` belonging to the given `DiceMagick.Characters.Character`.

  The `Result` generation can be performed more than once, with a single
  `Result` being returned based on the given `comparison_fun`.

  For example, using `Kernel.>/2` and `Kernel.</2`, you could model the
  advantage/disadvantage mechanic from Dungeons & Dragons 5th Edition.

  The faces for each `Result` will always be returned along with the final
  `Result`.

  ## Options

  * `times` - The number of times to roll, i.e. the number of `Result`s to
    generate
  * `comparison_fun` - A function that will be used to decide which `Result`
    will be returned

  ## Examples

      iex> roll("Stealth Check", character)
      {%Result{total: 10, expression: "1d20 + 3"}, [7]}

      iex> roll("Stealth Check", character, times: 2, comparison_fun: &Kernel.>/2)
      {%Result{total: 21, expression: "1d20 + 3"}, [2, 18]}

  """
  @spec roll(String.t(), State.t(), roll_opts()) :: {Result.t(), [integer()]}
  def roll(name, %State{character: character, rolls: rolls}, opts \\ []) do
    times = Keyword.get(opts, :times, 1)
    comparison_fun = Keyword.get(opts, :comparison_fun, &Kernel.==/2)

    roll = get_roll_by_name!(rolls, name)

    1..times
    |> Enum.map(fn _ ->
      roll
      |> Map.put(:character_id, character.id)
      |> Rolls.generate_result()
      |> Map.put(:name, name)
    end)
    |> process_results(comparison_fun)
  end

  @spec get_roll_by_name!([Rolls.Roll.t()], String.t()) :: Rolls.Roll.t()
  defp get_roll_by_name!(rolls, name) do
    case Enum.find(rolls, &(&1.name == name)) do
      nil -> raise ~s(Could not find roll named "#{name}")
      roll -> roll
    end
  end

  @spec process_results([Rolls.Result.t()], function()) :: {Rolls.Result.t(), [integer()]}
  defp process_results(results, comparison_fun) do
    first = List.first(results)

    Enum.reduce(results, first, fn cur, acc ->
      if comparison_fun.(cur.total, acc.total), do: cur, else: acc
    end)
  end

  @doc "TODO"
  @spec send_message(Rolls.Result.t(), Character.t(), keyword()) :: Rolls.Result.t()
  def send_message(result, character, opts \\ []) do
    require IEx
    IEx.pry()
    msg = Discord.roll_message(character, result, opts)
    Discord.send_message(character.discord_channel_id, msg)
    result
  end
end
