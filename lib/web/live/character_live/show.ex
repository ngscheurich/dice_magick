defmodule Web.CharacterLive.Show do
  use Phoenix.LiveView

  alias Characters

  @throttle_time 1000
  @discord_channel_id Application.get_env(:dice_magick, :discord_channel_id)

  @impl true
  def mount(%{"id" => character_id}, _session, socket) do
    character = Characters.get_character!(character_id, preload: [:rolls])

    Characters.Supervisor.add_worker(character_id)

    state = Characters.Worker.state(character_id)
    {:ok, assign(socket, character: character, rolls: state.rolls, can_update: true)}
  end

  @impl true
  def render(assigns), do: Phoenix.View.render(Web.CharacterView, "show.html", assigns)

  @impl true
  def handle_event("update", _params, %{assigns: %{character: character}} = socket) do
    state = Characters.Worker.update_sync(character.id)

    Process.send_after(self(), :unblock, @throttle_time)

    {:noreply, assign(socket, rolls: state.rolls, can_update: false)}
  end

  @impl true
  def handle_event(
        "roll",
        %{"name" => name},
        %{assigns: %{character: character, rolls: rolls}} = socket
      ) do
    [roll] = Enum.filter(rolls, &(&1.name == name))
    result = ExDiceRoller.roll(roll.expression)

    message = """
    **#{character.name}** rolls _#{roll.name}_ (`#{roll.expression}`)…
    :game_die: Result: **#{result}**
    """

    {discord_channel_id, _} = Integer.parse(@discord_channel_id)
    Nostrum.Api.create_message(discord_channel_id, message)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:unblock, socket), do: {:noreply, assign(socket, can_update: true)}
end
