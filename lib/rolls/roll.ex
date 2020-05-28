defmodule Rolls.Roll do
  @moduledoc """
  [todo] Write documentation
  """

  @type t :: %__MODULE__{}

  defstruct [
    :name,
    :expression,
    metadata: %{},
    favorite: false,
    tags: []
  ]
end
