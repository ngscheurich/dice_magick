defmodule DiceMagickWeb.PageController do
  @moduledoc false

  use DiceMagickWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
