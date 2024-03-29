defmodule DiceMagickWeb.SessionController do
  use DiceMagickWeb, :controller
  alias DiceMagick.Accounts

  plug Ueberauth

  def new(conn, _params), do: render(conn, "new.html")

  def create(%{assigns: %{ueberauth_failure: _}} = conn, _) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def create(%{assigns: %{ueberauth_auth: auth}} = conn, _) do
    case Accounts.find_or_create_user(auth) do
      {:ok, user} ->
        conn
        |> DiceMagickWeb.Auth.login(user)
        |> put_flash(:info, "Success! Welcome, #{user.nickname}.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def delete(conn, _) do
    conn
    |> DiceMagickWeb.Auth.logout()
    |> put_flash(:info, "You have been logged out!")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
