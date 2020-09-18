defmodule DiceMagickWeb.CharacterLive.Show do
  @moduledoc """
  TODO
  """

  use Phoenix.LiveView

  alias DiceMagick.{Characters, Discord, Rolls}
  alias DiceMagick.Characters.Character
  alias DiceMagickWeb.CharacterLive.{State, Helpers}

  @throttle_time 1000

  @impl true
  def mount(%{"id" => character_id}, _session, socket) do
    character = Characters.get_character!(character_id, preload: :roll_results)
    state = Characters.Worker.state(character_id)

    state = %State{
      character: character,
      results: Helpers.trim_results(character.roll_results),
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
  # TODO Change button style when allow_sync is false
  def handle_event("roll", _params, %{assigns: %{allow_sync: false}} = socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("roll", %{"name" => name, "type" => "advantage"}, socket) do
    state = State.from_socket(socket)
    {result, _} = Helpers.roll(name, state, times: 2, comparison_fun: &Kernel.>/2)
    Process.send_after(self(), :unblock, @throttle_time)
    {:noreply, assign(socket, results: state.results ++ [result], allow_sync: false)}
  end

  @impl true
  def handle_event("roll", %{"name" => name, "type" => "disadvantage"}, socket) do
    state = State.from_socket(socket)
    {result, _} = Helpers.roll(name, state, times: 2, comparison_fun: &Kernel.</2)
    Process.send_after(self(), :unblock, @throttle_time)
    {:noreply, assign(socket, results: state.results ++ [result], allow_sync: false)}
  end

  @impl true
  def handle_event("roll", %{"name" => name}, socket) do
    state = State.from_socket(socket)
    {result, _} = Helpers.roll(name, state)
    Process.send_after(self(), :unblock, @throttle_time)
    {:noreply, assign(socket, results: state.results ++ [result], allow_sync: false)}
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
  def handle_info(:unblock, socket), do: {:noreply, assign(socket, allow_sync: true)}
end
