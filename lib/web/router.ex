defmodule Web.Router do
  use Web, :router
  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {Web.LayoutView, :root}
    plug Web.Auth
  end

  pipeline :protected do
    # [todo] Configure username/password
    plug :basic_auth, username: "admin", password: "password"
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through [:browser, :protected]
      live_dashboard "/dashboard", metrics: Web.Telemetry
    end
  end

  scope "/", Web do
    pipe_through :browser

    get "/", PageController, :index
    resources "/sessions", SessionController, only: [:new, :delete]

    scope "/auth" do
      get "/:provider", SessionController, :request
      get "/:provider/callback", SessionController, :create
    end
  end

  scope "/manage", Web do
    pipe_through [:browser, :authenticate_user]

    live "/characters/new", CharacterLive.New
    live "/characters/:id/edit", CharacterLive.Edit

    resources "/characters", CharacterController, only: [:index, :show]
  end
end
