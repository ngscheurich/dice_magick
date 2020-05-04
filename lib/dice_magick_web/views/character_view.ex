defmodule DiceMagickWeb.CharacterView do
  use DiceMagickWeb, :view

  alias DiceMagickWeb.CharacterLive
  alias DiceMagick.Rolls.Roll

  # [todo] Documentation
  @spec roll_parts(Rolls.t()) :: String.t()
  def roll_parts(%Roll{parts: parts}) do
    parts
    |> Enum.map(fn %{num: num, sides: sides, mod: mod} ->
      str = "#{num}d#{sides}"

      cond do
        mod > 0 -> str <> " +#{mod}"
        mod < 0 -> str <> " #{mod}"
        true -> str
      end
    end)
    |> Enum.join(", ")
  end
end
