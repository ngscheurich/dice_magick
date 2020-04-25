defmodule DiceMagickWeb.Router do
  use DiceMagickWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DiceMagickWeb.Auth
  end

  scope "/", DiceMagickWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/auth", DiceMagickWeb do
    pipe_through :browser

    get "/login", SessionController, :new
    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :create
    delete "/logout", SessionController, :logout
  end
end
