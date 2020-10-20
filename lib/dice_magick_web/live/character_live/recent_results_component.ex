defmodule DiceMagickWeb.CharacterLive.RecentResultsComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
    <section class="border-b border-dashed border-gray-300">
      <h1 class="font-display text-2xl mb-2">Recent Results</h1>
      <table class="w-full text-xs border-l-4 border-cream-800">
        <tbody>
          <%= for result <- @results do %>
            <tr class="border-t border-r border-dashed border-gray-300">
              <td class="w-1/3 p-2 pr-10 font-medium"><%= result.name %></td>
              <td class="pr-2"><%= result.total %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </section>
    """
  end
end
