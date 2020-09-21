defmodule DiceMagick.Sources.GoogleSheets do
  @moduledoc """
  Implements `DiceMagick.Sources.Source` to provide functions for retrieving
  `DiceMagick.Rolls.Roll`s stored in a Google Sheets document.

  ## Params

    * `key` - The key of the Google Sheets spreadsheet to retrieve
    * `worksheet` - The positional or unique identifier of the worksheet to be processed

  ## Examples

      %{key: "1sEEi3cUfUqc-suoKGPhMQ0eh7KCPbn3ksgOZ-b5q3QI", worksheet: "4"}

  """

  @behaviour DiceMagick.Sources.Source

  alias DiceMagick.Rolls.Roll

  @google_sheets Application.get_env(:dice_magick, :google_sheets)
  @source_params [:key, :worksheet]

  @impl true
  defdelegate fetch_data(params), to: @google_sheets

  @impl true
  def validate_params(params) do
    @source_params
    |> Enum.reduce([], fn cur, acc ->
      case Map.get(params, cur) do
        nil -> acc ++ ["must include #{cur} param"]
        _ -> acc
      end
    end)
    |> case do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  @impl true
  def generate_rolls(%{"feed" => %{"entry" => rows}}) do
    rolls =
      Enum.map(rows, fn row ->
        %Roll{
          name: data(row, "name"),
          expression: data(row, "expression"),
          favorite: favorite(row),
          metadata: metadata(row),
          tags: tags(row)
        }
      end)

    {:ok, rolls}
  end

  def generate_rolls(_data), do: {:error, :invalid_data}

  @spec data(map, String.t()) :: term
  defp data(row, label), do: row["gsx$#{label}"]["$t"]

  @spec favorite(map()) :: boolean()
  defp favorite(row) do
    row
    |> data("favorite")
    |> String.downcase()
    |> case do
      "true" -> true
      _ -> false
    end
  end

  @spec metadata(map) :: map
  defp metadata(row) do
    row
    |> data("metadata")
    |> case do
      "" ->
        nil

      val ->
        val
        |> Jason.decode()
        |> case do
          {:ok, result} -> result
          error -> error
        end
    end
  end

  @spec tags(map) :: [String.t()]
  defp tags(row) do
    row
    |> data("tags")
    |> String.replace(" ", "")
    |> String.split(",")
  end
end
