defmodule DiceWizardWeb.Router do
  use DiceWizardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", DiceWizardWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/auth", DiceWizardWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end
end
