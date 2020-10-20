defmodule DiceMagickWeb.PageController do
  @moduledoc false

  use DiceMagickWeb, :controller

  def index(%{assigns: %{current_user: u}} = conn, _params) when not is_nil(u) do
    redirect(conn, to: Routes.character_path(conn, :index))
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
