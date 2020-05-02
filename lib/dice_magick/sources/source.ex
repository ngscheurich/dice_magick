defmodule DiceMagick.Source do
  @moduledoc """
  [todo] Write documentation
  """

  @type parsed() :: {:ok, [Roll.t()]} | {:error, any()}
  @type parts() :: {integer(), integer(), integer()}

  @callback name() :: atom()
  @callback encode(any()) :: parsed()
end
