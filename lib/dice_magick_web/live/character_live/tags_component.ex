defmodule DiceMagickWeb.CharacterLive.TagsComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
    <%= for tag <- @tags do %>
      <button class="tag" phx-value-tag="<%= tag %>" phx-click="apply-tag">
        <%= tag %>
      </button>
    <% end %>
    """
  end
end
