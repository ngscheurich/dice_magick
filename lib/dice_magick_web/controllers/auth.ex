defmodule DiceMagickWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias DiceMagick.{Accounts, Characters}
  alias DiceMagickWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(%{assigns: %{current_user: _}} = conn, _opts), do: conn

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user!(user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    user
    |> Characters.list_characters_for_user()
    |> Enum.each(&Characters.Supervisor.add_worker(&1.id))

    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn.assigns.current_user
    |> Characters.list_characters_for_user()
    |> Enum.each(&Characters.Worker.stop(&1.id))

    configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    case Map.get(conn.assigns, :current_user) do
      nil ->
        conn
        |> put_flash(:error, "You need to log in to do that, buddy.")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()

      _ ->
        conn
    end
  end
end
