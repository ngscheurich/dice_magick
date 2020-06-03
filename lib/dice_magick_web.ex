defmodule DiceMagickWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: DiceMagickWeb

      import Plug.Conn
      import DiceMagickWeb.Gettext
      import DiceMagickWeb.Auth, only: [authenticate_user: 2]
      import Phoenix.LiveView.Controller
      alias DiceMagickWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/dice_magick_web/templates",
        namespace: DiceMagickWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import DiceMagickWeb.ErrorHelpers
      import DiceMagickWeb.Gettext
      import Phoenix.LiveView.Helpers
      alias DiceMagickWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import DiceMagickWeb.Auth, only: [authenticate_user: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import DiceMagickWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
