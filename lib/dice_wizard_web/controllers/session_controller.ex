defmodule DiceWizardWeb.SessionController do
  use DiceWizardWeb, :controller
  plug Ueberauth

  alias DiceWizard.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(%{assigns: %{ueberauth_failure: _}} = conn, _) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def create(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    case Accounts.find_or_create_user(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Success! Welcome, #{user.nickname}.")
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def logout(conn, _) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
