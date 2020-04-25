defmodule DiceMagick.Stats do
  @spec calculate_modifier(integer()) :: integer() | nil
  def calculate_modifier(score) do
    cond do
      score == 1 -> -5
      Enum.member?(2..3, score) -> -4
      Enum.member?(4..5, score) -> -3
      Enum.member?(6..7, score) -> -2
      Enum.member?(8..9, score) -> -1
      Enum.member?(10..11, score) -> -0
      Enum.member?(12..13, score) -> 1
      Enum.member?(14..15, score) -> 2
      Enum.member?(16..17, score) -> 3
      Enum.member?(18..19, score) -> 4
      Enum.member?(20..21, score) -> 5
      Enum.member?(22..23, score) -> 6
      Enum.member?(24..25, score) -> 7
      Enum.member?(26..27, score) -> 8
      Enum.member?(28..29, score) -> 9
      score >= 30 -> 10
      score < 1 -> nil
    end
  end
end
