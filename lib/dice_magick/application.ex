defmodule DiceMagick.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      DiceMagick.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: DiceMagick.PubSub},
      # Start the endpoint when the application starts
      DiceMagickWeb.Endpoint
      # Starts a worker by calling: DiceMagick.Worker.start_link(arg)
      # {DiceMagick.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DiceMagick.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DiceMagickWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
