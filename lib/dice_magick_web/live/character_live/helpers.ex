defmodule DiceMagickWeb.CharacterLive.Helpers do
  @moduledoc """
  Helper functions for the `DiceMagickWeb.CharacterLive` module.
  """

  alias DiceMagick.Rolls
  alias DiceMagick.Rolls.Roll
  alias DiceMagickWeb.CharacterLive.State

  @doc """
  TODO
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
  TODO
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
  TODO
  """
  @spec trim_results([Rolls.Result.t()]) :: [Rolls.Result.t()]
  def trim_results([]), do: []

  def trim_results(results) do
    results
    |> Enum.chunk_every(12)
    |> List.first()
  end

  @doc """
  TODO
  """
  @spec format_synced_at(DateTime.t()) :: String.t()
  def format_synced_at(dt) do
    case Timex.Format.DateTime.Formatters.Relative.format!(dt, "{relative}") do
      "now" -> "Just now"
      str -> str
    end
  end

  @type roll_opts() :: [times: integer(), comparison_fun: String.t()]

  @doc """
  TODO
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

  @doc """
  TODO
  """
  @spec get_roll_by_name!([Rolls.Roll.t()], String.t()) :: Rolls.Roll.t()
  def get_roll_by_name!(rolls, name) do
    case Enum.find(rolls, &(&1.name == name)) do
      nil -> raise ~s(Could not find roll named "#{name}")
      roll -> roll
    end
  end

  @doc """
  TODO
  """
  @spec process_results([Rolls.Result.t()], function()) :: {Rolls.Result.t(), [integer()]}
  def process_results(results, comparison_fun) do
    first = List.first(results)

    Enum.reduce(results, {first, []}, fn cur, {prev, faces} ->
      next = if comparison_fun.(cur.total, prev.total), do: cur, else: prev
      faces_total = Enum.reduce(cur.faces, &(&1 + &2))
      {next, faces ++ [faces_total]}
    end)
  end
end
