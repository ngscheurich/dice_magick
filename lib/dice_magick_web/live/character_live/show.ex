defmodule DiceMagickWeb.CharacterLive.Show do
  @moduledoc false

  use Phoenix.LiveView
  require Logger
  alias DiceMagick.{Characters, Discord, Rolls}

  @throttle_time 1000

  @impl true
  def mount(%{"id" => character_id}, _session, socket) do
    character = Characters.get_character!(character_id, preload: :roll_results)
    state = Characters.Worker.state(character_id)
    {favorites, rolls} = favorites(state.rolls)

    state = %{
      character: character,
      rolls: rolls,
      active_rolls: favorites,
      tags: state.tags,
      active_tags: [],
      allow_sync: true,
      synced_at: format_synced_at(state.synced_at),
      roll_results: trim_results(character.roll_results),
      last_result: %{},
      last_highlighted: false
    }

    {:ok, assign(socket, state)}
  end

  @spec trim_results([map]) :: [map]
  defp trim_results([]), do: []
  defp trim_results(results), do: results |> Enum.chunk_every(12) |> List.first()

  @spec format_synced_at(DateTime.t()) :: String.t()
  defp format_synced_at(dt) do
    case Timex.Format.DateTime.Formatters.Relative.format!(dt, "{relative}") do
      "now" -> "Just now"
      str -> str
    end
  end

  @impl true
  def render(assigns), do: Phoenix.View.render(DiceMagickWeb.CharacterView, "show.html", assigns)

  @impl true
  def handle_event("sync", _params, %{assigns: %{character: character}} = socket) do
    %{rolls: rolls, synced_at: synced_at} = Characters.Worker.update_sync(character.id)
    Process.send_after(self(), :unblock, @throttle_time)

    {:noreply,
     assign(socket, rolls: rolls, synced_at: format_synced_at(synced_at), allow_sync: false)}
  end

  @impl true
  def handle_event("roll", %{"name" => name}, socket) do
    %{
      assigns: %{
        character: character,
        active_rolls: active_rolls,
        rolls: rolls,
        roll_results: results
      }
    } = socket

    all_rolls = rolls ++ active_rolls

    [roll] = Enum.filter(all_rolls, &(&1.name == name))
    roll = %{roll | character_id: character.id}

    result = Rolls.generate_result(roll) |> Map.put(:name, name)
    message = Discord.roll_message(character.name, result, roll_name: name)
    Discord.send_message(character.discord_channel_id, message)

    roll_results = ([result] ++ results) |> trim_results()
    last_result = result

    Process.send_after(self(), :remove_highlight, 2000)

    {:noreply,
     assign(socket,
       roll_results: roll_results,
       last_result: last_result,
       last_highlighted: true
     )}
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
  def handle_info(:unblock, socket), do: {:noreply, assign(socket, allow_sync: true)}

  @impl true
  def handle_info(:remove_highlight, socket) do
    {:noreply, assign(socket, last_highlighted: false)}
  end

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
