defmodule Web.CharacterLive.Show do
  use Phoenix.LiveView

  alias Characters

  @impl true
  def mount(%{"id" => character_id}, _session, socket) do
    character = Characters.get_character!(character_id, preload: [:rolls])
    state = Characters.Worker.state(character)
    {:ok, assign(socket, character: character, rolls: state.character.rolls)}
  end

  @impl true
  def render(assigns), do: Phoenix.View.render(Web.CharacterView, "show.html", assigns)

  @impl true
  def handle_event("update", _params, %{assigns: %{character: character}} = socket) do
    Characters.Worker.update(character)
    state = Characters.Worker.state(character)
    {:noreply, assign(socket, rolls: state.character.rolls)}
  end
end
