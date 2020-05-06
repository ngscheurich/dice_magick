defmodule DiceMagick.Rolls.CSVEncoder do
  @moduledoc """
  Translates CSV data to `DiceMagick.Roll.Roll`s.
  """

  alias DiceMagick.Rolls.{Encoder, Roll, Parsers}

  @behaviour Encoder

  @impl true
  def format, do: :csv

  @impl true
  def encode(data) do
    data
    |> NimbleCSV.RFC4180.parse_string(skip_headers: false)
    |> encode_rows([])
  end

  @typep row() :: [String.t()]

  @spec encode_rows(String.t()) :: Encoder.result()
  defp encode_rows(error_msg), do: {:error, error_msg}

  @spec encode_rows([row()], [Roll.t()]) :: Encoder.result()
  defp encode_rows([], parsed), do: {:ok, parsed}

  defp encode_rows([head | tail], acc) do
    case encode_row(head) do
      error_msg when is_binary(error_msg) -> encode_rows(error_msg)
      row -> encode_rows(tail, acc ++ [row])
    end
  end

  @spec encode_row(row()) :: Roll.t() | String.t()
  defp encode_row([name, parts]) do
    parsed_parts =
      parts
      |> String.replace(" ", "")
      |> String.split("&")
      |> parse_parts([])

    case parsed_parts do
      error_msg when is_binary(error_msg) ->
        error_msg

      parts ->
        part_structs =
          Enum.map(parts, fn {num, sides, mod} ->
            %Roll.Part{num: num, sides: sides, mod: mod}
          end)

        %Roll{name: name, parts: part_structs}
    end
  end

  defp encode_row(_row), do: "Unable to parse data"

  @spec parse_parts([String.t()], [Encoder.parts()] | String.t()) ::
          [{integer(), integer(), integer()}] | String.t()
  defp parse_parts(_, error_msg) when is_binary(error_msg), do: error_msg
  defp parse_parts([], parsed), do: parsed

  defp parse_parts([head | tail], acc) do
    next =
      case Parsers.roll_part(head) do
        {:ok, [num, sides, "+", mod], _, _, _, _} -> acc ++ [{num, sides, mod}]
        {:ok, [num, sides, "-", mod], _, _, _, _} -> acc ++ [{num, sides, -mod}]
        {:ok, [num, sides], _, _, _, _} -> acc ++ [{num, sides, 0}]
        {:error, error_msg, _, _, _, _} -> error_msg
      end

    parse_parts(tail, next)
  end
end
