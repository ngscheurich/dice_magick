defmodule DiceMagickWeb.PageControllerTest do
  use DiceMagickWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Will you log in with Discord?"
  end
end
