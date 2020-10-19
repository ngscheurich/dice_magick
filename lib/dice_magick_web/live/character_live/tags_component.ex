defmodule DiceMagickWeb.CharacterLive.TagsComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
    <%= for tag <- @tags do %>
      <button class="block px-3 py-1 rounded-full antialiased bg-primary text-cream-100 tracking-wide text-xs" phx-value-tag="<%= tag %>" phx-click="apply-tag">
        <%= tag %>
      </button>
    <% end %>
    """
  end
end
