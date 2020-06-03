defmodule DiceMagickWeb.CharacterLive.New do
  @moduledoc false

  use Phoenix.LiveView

  alias DiceMagickWeb.Router.Helpers, as: Routes
  alias DiceMagick.Characters
  alias DiceMagick.Characters.Character

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    changeset = Characters.change_character(%Character{}, %{})
    {:ok, assign(socket, user_id: user_id, changeset: changeset, key: "", worksheet: "")}
  end

  @impl true
  def render(assigns), do: Phoenix.View.render(DiceMagickWeb.CharacterView, "new.html", assigns)

  @impl true
  def handle_event("update", params, socket) do
    %{"character" => character_params, "key" => key, "worksheet" => worksheet} = params
    character_params = Map.put(character_params, "user_id", socket.assigns.user_id)

    changeset =
      %Character{}
      |> Characters.change_character(character_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset, key: key, worksheet: worksheet)}
  end

  @impl true
  def handle_event("save", params, socket) do
    %{"character" => character_params, "key" => key, "worksheet" => worksheet} = params

    character_params =
      character_params
      |> Map.put("user_id", socket.assigns.user_id)
      |> Map.put("source_params", %{key: key, worksheet: worksheet})

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
