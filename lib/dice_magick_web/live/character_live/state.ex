defmodule DiceMagickWeb.CharacterLive.State do
  @moduledoc """
  The state of a `DiceMagickWeb.CharacterLive` LiveView socket.
  """

  alias DiceMagick.Characters.Character
  alias DiceMagick.Rolls.{Roll, Result}
  alias Phoenix.LiveView
  alias LiveView.Socket

  @enforce_keys [
    :character,
    :synced_at,
    :selected,
    :rolls,
    :tags
  ]
  @type t() :: %__MODULE__{}

  defstruct [
    :character,
    :synced_at,
    :selected,
    rolls: [],
    grouped_rolls: {[], []},
    tags: [],
    active_tags: [],
    allow_sync: true,
    results: []
  ]

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = state), do: Map.from_struct(state)

  @spec from_map(map()) :: t()
  def from_map(map), do: struct(__MODULE__, map)

  @spec from_socket(Socket.t()) :: t()
  def from_socket(%{assigns: assigns}), do: from_map(assigns)

  @spec assign_state(t(), Socket.t()) :: any()
  def assign_state(%__MODULE__{} = state, socket) do
    attrs = to_map(state)
    LiveView.assign(socket, attrs)
  end
end
