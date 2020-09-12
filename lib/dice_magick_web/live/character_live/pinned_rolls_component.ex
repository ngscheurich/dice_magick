defmodule DiceMagickWeb.CharacterLive.PinnedRollsComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
    <%= for roll <- @rolls do %>
      <div class="roll-btn">
        <button class="roll-btn__main" phx-click="roll" phx-value-name="<%= roll.name %>">
          <%= roll.name %>
        </button>
        <button class="roll-btn__more">More</button>
      </div>
    <% end %>
    """
  end
end
