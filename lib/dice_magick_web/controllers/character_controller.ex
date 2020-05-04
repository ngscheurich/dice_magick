defmodule DiceMagickWeb.CharacterController do
  use DiceMagickWeb, :controller

  alias DiceMagick.Characters

  def index(conn, _) do
    %{assigns: %{current_user: current_user}} = conn
    characters = Characters.list_characters_for_user(current_user)
    render(conn, "index.html", characters: characters)
  end

  def show(conn, %{"id" => id}) do
    %{assigns: %{current_user: current_user}} = conn
    character = Characters.get_character!(id, preload: [:rolls])

    if character.user_id == current_user.id do
      render(conn, "show.html", character: character)
    else
      conn
      |> text("That doesn’t belong to you.")
      |> halt()
    end
  end
end
