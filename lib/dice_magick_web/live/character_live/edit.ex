defmodule DiceMagickWeb.CharacterLive.Edit do
  use Phoenix.LiveView

  alias DiceMagickWeb.Router.Helpers, as: Routes
  alias DiceMagick.Characters

  @impl true
  def mount(%{"id" => character_id}, %{"user_id" => _current_user_id}, socket) do
    character = Characters.get_character!(character_id)

    # [todo] Handle case where user is not allowed to edit character
    # if character.user_id !== current_user_id, do:

    changeset = Characters.change_character(character, %{})

    {:ok,
     assign(socket,
       character: character,
       changeset: changeset,
       key: character.source_params["key"],
       worksheet: character.source_params["worksheet"]
     )}
  end

  @impl true
  def render(assigns), do: Phoenix.View.render(DiceMagickWeb.CharacterView, "edit.html", assigns)

  @impl true
  def handle_event("update", params, socket) do
    %{"character" => character_params, "key" => key, "worksheet" => worksheet} = params
    character_params = Map.delete(character_params, "roll_data")

    changeset =
      socket.assigns.character
      |> Characters.change_character(character_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset, key: key, worksheet: worksheet)}
  end

  @impl true
  def handle_event("save", params, socket) do
    %{"character" => character_params, "key" => key, "worksheet" => worksheet} = params

    character_params =
      Map.put(character_params, "source_params", %{key: key, worksheet: worksheet})

    case Characters.update_character(socket.assigns.character, character_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Character updated")
         |> redirect(
           to:
             Routes.live_path(socket, DiceMagickWeb.CharacterLive.Show, socket.assigns.character)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
