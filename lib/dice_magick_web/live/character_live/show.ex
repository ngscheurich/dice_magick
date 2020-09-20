defmodule DiceMagickWeb.CharacterLive.Show do
  @moduledoc """
  Implements `GenServer` callbacks to provide a `Phoenix.LiveView` module for
  main application UI.
  """

  use Phoenix.LiveView

  alias DiceMagick.Characters
  alias DiceMagickWeb.CharacterLive.{State, Helpers}

  @sync_throttle 1000
  @roll_throttle 500
  @results_shown 12

  @impl true
  def mount(%{"id" => character_id}, _session, socket) do
    character = Characters.get_character!(character_id, preload: :roll_results)
    state = Characters.Worker.state(character_id)

    state = %State{
      character: character,
      results: Enum.take(character.roll_results, @results_shown),
      synced_at:
        case state.synced_at do
          nil -> ""
          datetime -> Helpers.format_synced_at(datetime)
        end,
      selected: nil,
      rolls: state.rolls,
      grouped_rolls: Helpers.group_rolls_by_favorites(state.rolls),
      tags: state.tags
    }

    {:ok, State.assign_state(state, socket)}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(DiceMagickWeb.CharacterView, "show.html", assigns)
  end

  ## Callbacks

  @impl true
  def handle_event("sync", _params, %{assigns: %{character: character}} = socket) do
    %{rolls: rolls, synced_at: synced_at} = Characters.Worker.update_sync(character.id)

    Process.send_after(self(), :unblock_sync, @sync_throttle)

    {:noreply,
     assign(socket,
       rolls: rolls,
       synced_at: Helpers.format_synced_at(synced_at),
       allow_sync: false
     )}
  end

  @impl true
  def handle_event("roll", _params, %{assigns: %{allow_roll: false}} = socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("roll", %{"name" => name, "type" => "advantage"}, socket) do
    state = State.from_socket(socket)
    {result, _} = Helpers.roll(name, state, times: 2, comparison_fun: &Kernel.>/2)
    Process.send_after(self(), :unblock_roll, @roll_throttle)
    {:noreply, assign(socket, results: state.results ++ [result], allow_roll: false)}
  end

  @impl true
  def handle_event("roll", %{"name" => name, "type" => "disadvantage"}, socket) do
    state = State.from_socket(socket)
    {result, _} = Helpers.roll(name, state, times: 2, comparison_fun: &Kernel.</2)
    Process.send_after(self(), :unblock_roll, @roll_throttle)
    {:noreply, assign(socket, results: state.results ++ [result], allow_roll: false)}
  end

  @impl true
  def handle_event("roll", %{"name" => name}, socket) do
    state = State.from_socket(socket)
    {result, _} = Helpers.roll(name, state)
    Process.send_after(self(), :unblock_roll, @roll_throttle)
    {:noreply, assign(socket, results: state.results ++ [result], allow_roll: false)}
  end

  @impl true
  def handle_event("apply-tag", %{"tag" => tag}, socket) do
    %{rolls: rolls, active_tags: active_tags} = State.from_socket(socket)

    active_tags =
      case Enum.member?(active_tags, tag) do
        true -> Enum.filter(active_tags, &(&1 != tag))
        false -> active_tags ++ [tag]
      end

    grouped_rolls = Helpers.group_rolls_by_tags(rolls, active_tags)
    {:noreply, assign(socket, active_tags: active_tags, grouped_rolls: grouped_rolls)}
  end

  @impl true
  def handle_info(:unblock_sync, socket), do: {:noreply, assign(socket, allow_sync: true)}

  @impl true
  def handle_info(:unblock_roll, socket), do: {:noreply, assign(socket, allow_roll: true)}
end
