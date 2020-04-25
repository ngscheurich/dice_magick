defmodule DiceMagickWeb.Router do
  use DiceMagickWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {DiceMagickWeb.LayoutView, :root}
    plug DiceMagickWeb.Auth
  end

  scope "/", DiceMagickWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/sessions", SessionController, only: [:new, :delete]

    scope "/auth" do
      get "/:provider", SessionController, :request
      get "/:provider/callback", SessionController, :create
    end
  end


  end
end
