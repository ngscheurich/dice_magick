defmodule DiceWizardWeb.PageController do
  use DiceWizardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
