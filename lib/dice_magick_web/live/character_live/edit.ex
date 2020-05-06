defmodule DiceMagickWeb.CharacterLive.Edit do
  use Phoenix.LiveView

  alias DiceMagickWeb.Router.Helpers, as: Routes
  alias DiceMagick.Characters

  @impl true
  def mount(%{"id" => character_id}, %{"user_id" => _current_user_id}, socket) do
    character = Characters.get_character!(character_id, preload: [:rolls])

    # [todo] Handle case where user is not allowed to edit character
    # if character.user_id !== current_user_id, do:

    changeset = Characters.change_character(character, %{})
    {:ok, assign(socket, character: character, changeset: changeset)}
  end

  @impl true
  def render(assigns), do: Phoenix.View.render(DiceMagickWeb.CharacterView, "edit.html", assigns)

  @impl true
  def handle_event("update", %{"character" => character_params}, socket) do
    character_params = Map.delete(character_params, "roll_data")

    changeset =
      socket.assigns.character
      |> Characters.change_character(character_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"character" => character_params}, socket) do
    case Characters.update_character(socket.assigns.character, character_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Character updated")
         |> redirect(to: Routes.character_path(socket, :show, socket.assigns.character))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
