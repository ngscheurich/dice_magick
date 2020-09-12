defmodule DiceMagickWeb.CharacterLive.SidebarComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias DiceMagick.Characters.Character

  def render(assigns) do
    ~L"""
    <section class="sidebar">
      <div class="sidebar__character">
        <img class="sidebar__avatar" src="/images/dust.png" />
        <div class="sidebar__color"></div>
      </div>

      <h1 class="sidebar__name">Dust the Archivist</h1>

      <div class="sidebar__info">
        <dl>
          <dt>Source:</dt>
          <dd>
            <%= link "Google Sheets", target: "_blank",
                  to: google_sheets_url(@character) %>
          </dd>
        </dl>

        <dl>
          <dt>Updated:</dt>
          <dd><%= @synced_at %></dd>
        </dl>
      </div>

      <button phx-click="sync" phx-throttle="3000">Sync Rolls</button>

      <div id="color-picker"></div>
    </section>
    """
  end

  defp google_sheets_url(%Character{source_params: %{"key" => key}}) do
    "https://docs.google.com/spreadsheets/d/#{key}"
  end
end
