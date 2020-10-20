defmodule DiceMagickWeb.CharacterLive.SidebarComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias DiceMagick.Characters.Character

  def render(assigns) do
    ~L"""
    <section class="sidebar p-8 pt-24 bg-slate-800 text-cream-200 tracking-wide antialiased">
      <div class="mb-8">
        <img class="w-32 h-32 rounded-full" src="/images/dust.png" />
        <div class="sidebar__color"></div>
      </div>

      <h1 class="mb-16 font-display text-5xl leading-none">Dust the Archivist</h1>

      <div class="mb-4 text-sm">
        <dl>
          <dt class="inline">Source:</dt>
          <dd class="inline">
            <%= link "Google Sheets", target: "_blank",
                  to: google_sheets_url(@character) %>
          </dd>
        </dl>

        <dl>
          <dt class="inline">Updated:</dt>
          <dd class="inline"><%= @synced_at %></dd>
        </dl>
      </div>

      <button class="bg-slate-400 text-xs px-4 py-1 rounded-sm" phx-click="sync" phx-throttle="3000">Sync Rolls</button>

      <div id="color-picker"></div>
    </section>
    """
  end

  defp google_sheets_url(%Character{source_params: %{"key" => key}}) do
    "https://docs.google.com/spreadsheets/d/#{key}"
  end
end
