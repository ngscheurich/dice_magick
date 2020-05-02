defmodule DiceMagick.Rolls.Parsers do
  @moduledoc """
  Defines string parsers that aid in ranslating data to
  `DiceMagick.Roll.Roll`s.
  """

  import NimbleParsec

  modifier =
    [string("+"), string("-")]
    |> choice()
    |> integer(min: 1)
    |> optional()

  defparsec(
    :roll_part,
    integer(min: 1)
    |> ignore(string("d"))
    |> integer(min: 1, max: 999)
    |> concat(modifier)
  )
end
