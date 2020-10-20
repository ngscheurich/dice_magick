defmodule DiceMagick.Rolls.Roll do
  @moduledoc """
  A `struct` representing a TTRPG roll. `Roll`s are not persisted by the
  application, but are rather read on-demand from external
  `DiceMagick.Sources.Source`s.



  ## Fields

  * `name` (required) - The name of the `Roll`
  * `expression` (required) - The expression that should be evaluated this is rolled
  * `is_favorite` - Whether or not this is a favorite roll
  * `tags` - A list of tags attached to the `Roll`
  * `metadata` - The JSON metadata attached to the `Roll`

  """

  @type t :: %__MODULE__{}
  @enforce_keys [:name, :expression]

  defstruct [
    :name,
    :expression,
    :character_id,
    favorite: false,
    tags: [],
    metadata: %{}
  ]
end
