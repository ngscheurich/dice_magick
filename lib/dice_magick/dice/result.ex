defmodule DiceMagick.Dice.Result do
  @moduledoc """
  The result of evaluating a dice expression.

  ## Fields

  * `expression` - The expression that was evaluated
  * `faces` - A list of the result (upward face) of every die rolled
  * `total` - The sum of all die faces and modifiers

  """

  @type t :: %__MODULE__{}
  defstruct [:expression, :total, faces: []]
end
