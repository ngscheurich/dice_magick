defmodule DiceMagickWeb.PageControllerTest do
  use DiceMagickWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Dice Magick"
  end
end
