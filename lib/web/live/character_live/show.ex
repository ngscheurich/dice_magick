defmodule Web.CharacterLive.Show do
  use Phoenix.LiveView
  alias Characters

  @throttle_time 1000
  @discord_channel_id Application.get_env(:dice_magick, :discord_channel_id)

  @impl true
  def mount(%{"id" => character_id}, _session, socket) do
    character = Characters.get_character!(character_id)

    Characters.Supervisor.add_worker(character_id)
    worker = Characters.Worker.state(character_id)
    {favorites, rolls} = favorites(worker.rolls)

    state = %{
      character: character,
      rolls: rolls,
      active_rolls: favorites,
      tags: worker.tags,
      active_tags: [],
      can_update: true
    }

    {:ok, assign(socket, state)}
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
  def handle_event("roll", %{"name" => name}, socket) do
    %{assigns: %{character: character, rolls: rolls}} = socket
    [roll] = Enum.filter(rolls, &(&1.name == name))
    result = ExDiceRoller.roll(roll.expression)

    # [todo] Extract into shared function
    message = """
    **#{character.name}** rolls _#{roll.name}_ (`#{roll.expression}`)…
    :game_die: Result: **#{result}**
    """

    {discord_channel_id, _} = Integer.parse(@discord_channel_id)
    Nostrum.Api.create_message(discord_channel_id, message)

    {:noreply, socket}
  end

  @impl true
  def handle_event("apply-tag", %{"tag" => tag}, socket) do
    %{assigns: %{rolls: rolls, active_rolls: active_rolls, active_tags: active_tags}} = socket

    active_tags =
      case Enum.member?(active_tags, tag) do
        true -> Enum.filter(active_tags, &(&1 != tag))
        false -> active_tags ++ [tag]
      end

    all_rolls = active_rolls ++ rolls

    active_rolls =
      case Enum.count(active_tags) do
        0 ->
          {favorites, _} = favorites(all_rolls)
          favorites

        _ ->
          Enum.filter(all_rolls, fn roll ->
            Enum.any?(roll.tags, &Enum.member?(active_tags, &1))
          end)
      end

    rolls = Enum.filter(all_rolls, fn roll -> !Enum.member?(active_rolls, roll) end)

    {:noreply,
     assign(socket, %{active_tags: active_tags, rolls: rolls, active_rolls: active_rolls})}
  end

  @impl true
  def handle_info(:unblock, socket), do: {:noreply, assign(socket, can_update: true)}

  # Helpers

  @spec favorites([map]) :: {[map], [map]}
  defp favorites(rolls) do
    Enum.reduce(rolls, {[], []}, fn cur, {favorites, rest} ->
      case cur.favorite do
        true -> {favorites ++ [cur], rest}
        false -> {favorites, rest ++ [cur]}
      end
    end)
  end
end
