defmodule DiceMagickWeb.CharacterControllerTest do
  use DiceMagickWeb.ConnCase

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([get(conn, Routes.character_path(conn, :index))], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  describe "index" do
    test "lists all characters for current user", %{conn: conn} do
      user = insert(:user)
      insert(:character, user: user, name: "Baldur")
      insert(:character, name: "Ophelia")

      conn =
        conn
        |> authenticate(user)
        |> get(Routes.character_path(conn, :index))

      assert html_response(conn, 200) =~ "Your Characters"
      assert html_response(conn, 200) =~ "Baldur"
      refute html_response(conn, 200) =~ "Ophelia"
    end
  end

  # describe "new" do
  #   test "renders character form", %{conn: conn} do
  #     conn =
  #       conn
  #       |> authenticate()
  #       |> get(Routes.character_path(conn, :new))

  #     assert html_response(conn, 200) =~ "New Character"
  #   end
  # end

  # describe "create character" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     conn = post(conn, Routes.character_path(conn, :create), character: @create_attrs)

  #     assert %{id: id} = redirected_params(conn)
  #     assert redirected_to(conn) == Routes.character_path(conn, :show, id)

  #     conn = get(conn, Routes.character_path(conn, :show, id))
  #     assert html_response(conn, 200) =~ "Show Character"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, Routes.character_path(conn, :create), character: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "New Character"
  #   end
  # end

  # describe "edit character" do
  #   setup [:create_character]

  #   test "renders form for editing chosen character", %{conn: conn, character: character} do
  #     conn = get(conn, Routes.character_path(conn, :edit, character))
  #     assert html_response(conn, 200) =~ "Edit Character"
  #   end
  # end

  # describe "update character" do
  #   setup [:create_character]

  #   test "redirects when data is valid", %{conn: conn, character: character} do
  #     conn = put(conn, Routes.character_path(conn, :update, character), character: @update_attrs)
  #     assert redirected_to(conn) == Routes.character_path(conn, :show, character)

  #     conn = get(conn, Routes.character_path(conn, :show, character))<%= if schema.string_attr do %>
  #     assert html_response(conn, 200) =~ <%= inspect Mix.Phoenix.Schema.default_param(schema, :update) %><% else %>
  #     assert html_response(conn, 200)<% end %>
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, character: character} do
  #     conn = put(conn, Routes.character_path(conn, :update, character), character: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "Edit Character"
  #   end
  # end

  # describe "delete character" do
  #   setup [:create_character]

  #   test "deletes chosen character", %{conn: conn, character: character} do
  #     conn = delete(conn, Routes.character_path(conn, :delete, character))
  #     assert redirected_to(conn) == Routes.character_path(conn, :index)
  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.character_path(conn, :show, character))
  #     end
  #   end
  # end

  # defp create_character(_) do
  #   character = fixture(:character)
  #   %{character: character}
  # end
end
