defmodule DiceMagickWeb.CharacterController do
  use DiceMagickWeb, :controller

  alias DiceMagick.Characters

  def index(conn, _) do
    %{assigns: %{current_user: current_user}} = conn
    characters = Characters.list_characters_for_user(current_user)
    render(conn, "index.html", characters: characters)
  end
end
