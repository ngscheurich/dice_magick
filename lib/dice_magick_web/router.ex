defmodule DiceMagickWeb.Router do
  @moduledoc false

  use DiceMagickWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {DiceMagickWeb.LayoutView, :root}
    plug DiceMagickWeb.Auth
  end

  pipeline :protected do
    # [todo] Configure username/password
    plug :basic_auth, username: "admin", password: "password"
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through [:browser, :protected]
      live_dashboard "/dashboard", metrics: DiceMagickWeb.Telemetry
    end
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

  scope "/manage", DiceMagickWeb do
    pipe_through [:browser, :authenticate_user]

    live "/characters/new", CharacterLive.New
    live "/characters/:id", CharacterLive.Show
    live "/characters/:id/edit", CharacterLive.Edit

    resources "/characters", CharacterController, only: [:index]
  end
end
