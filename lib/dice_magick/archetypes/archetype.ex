defmodule DiceMagick.Archetype do
  @moduledoc """
  Defines a type of character derived from a particular TTRPG system.
  """

  @callback name() :: atom()
  @callback encode(map()) :: {:ok, map()} | {:error, keyword()}
  # @callback decode(map()) :: {:ok, map()} | {:error, keyword()}
end
