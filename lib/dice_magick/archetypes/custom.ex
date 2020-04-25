defmodule DiceMagick.Archetypes.Custom do
  @moduledoc """
  An unconstrained archetype suitable for use with any game system.
  """

  @behaviour DiceMagick.Archetype

  @impl true
  def name, do: :custom

  @impl true
  def encode(stats), do: {:ok, stats}
end
