defmodule DiceMagickWeb.CharacterLive.New do
  use Phoenix.LiveView

  alias DiceMagickWeb.Router.Helpers, as: Routes
  alias DiceMagick.Characters
  alias DiceMagick.Characters.Character

  @default_scores %{
    strength: 10,
    dexterity: 10,
    constitution: 10,
    intelligence: 10,
    wisdom: 10,
    charisma: 10
  }

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    changeset = Characters.change_character(%Character{}, %{stats: @default_scores})
    {:ok, assign(socket, user_id: user_id, changeset: changeset)}
  end

  @impl true
  def render(assigns), do: Phoenix.View.render(DiceMagickWeb.CharacterView, "new.html", assigns)

  @impl true
  def handle_event("update", %{"character" => character_params}, socket) do
    character_params = Map.put(character_params, "user_id", socket.assigns.user_id)

    changeset =
      %Character{}
      |> Characters.change_character(character_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"character" => character_params}, socket) do
    character_params = Map.put(character_params, "user_id", socket.assigns.user_id)

    case Characters.create_character(character_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Character created")
         |> redirect(to: Routes.character_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
