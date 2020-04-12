defmodule DiceMagickWeb.AuthTest do
  use DiceMagickWeb.ConnCase
  import Plug.Test

  alias DiceMagickWeb.Auth

  test "call with user_id assigns current_user", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> init_test_session(%{user_id: user.id})
      |> Auth.call(Auth.init([]))

    assert conn.assigns.current_user == user
  end

  test "call with no user_id sets current_user assign to nil", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> Auth.call(Auth.init([]))

    assert conn.assigns.current_user == nil
  end
end
