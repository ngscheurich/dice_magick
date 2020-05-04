defmodule DiceMagick.Rolls.Encoder do
  @moduledoc """
  Behaviour specification for modules that translate data to
  `DiceMagick.Roll.Roll`s.
  """

  @type result() :: {:ok, [Roll.t()]} | {:error, any()}

  @callback format() :: atom()
  @callback encode(any()) :: result()
end
