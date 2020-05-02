defmodule DiceMagick.Sources.CSV do
  @moduledoc """
  [todo] Write documentation
  """

  alias DiceMagick.Source
  alias DiceMagick.Rolls.Roll

  @behaviour DiceMagick.Source

  @impl true
  def name, do: :csv

  @impl true
  def encode(data) do
    data
    |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
    |> parse_rows([])
  end

  @typep row() :: [String.t()]

  @spec parse_rows(String.t()) :: Source.parsed()
  defp parse_rows(error_msg), do: {:error, error_msg}

  @spec parse_rows([row()], [Roll.t()]) :: Source.parsed()
  defp parse_rows([], parsed), do: {:ok, parsed}

  defp parse_rows([head | tail], acc) do
    case parse_row(head) do
      error_msg when is_binary(error_msg) -> parse_rows(error_msg)
      row -> parse_rows(tail, acc ++ [row])
    end
  end

  @spec parse_row(row()) :: Roll.t() | String.t()
  defp parse_row([name, parts]) do
    parsed_parts =
      parts
      |> String.replace(" ", "")
      |> String.split(",")
      |> parse_parts([])

    case parsed_parts do
      error_msg when is_binary(error_msg) -> error_msg
      parts -> %Roll{name: name, parts: parts}
    end
  end

  @spec parse_parts([String.t()], [Source.parts()] | String.t()) :: [Source.parts()] | String.t()
  defp parse_parts(_, error_msg) when is_binary(error_msg), do: error_msg
  defp parse_parts([], parsed), do: parsed

  defp parse_parts([head | tail], acc) do
    next =
      case DiceMagick.Parsers.roll_part(head) do
        {:ok, [num, die, "+", mod], _, _, _, _} -> acc ++ [{num, die, mod}]
        {:ok, [num, die, "-", mod], _, _, _, _} -> acc ++ [{num, die, -mod}]
        {:ok, [num, die], _, _, _, _} -> acc ++ [{num, die, 0}]
        {:error, error_msg, _, _, _, _} -> error_msg
      end

    parse_parts(tail, next)
  end
end
