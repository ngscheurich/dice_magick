defmodule DiceMagick.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defmodule CharacterWorkers do
    use GenServer

    def start_link(_), do: GenServer.start_link(__MODULE__, :ok)

    @impl true
    def init(:ok) do
      Characters.Character
      |> Repo.all()
      |> Enum.each(&Characters.Supervisor.add_worker(&1.id))

      :ignore
    end
  end

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PubSub},
      # Start the endpoint when the application starts
      Web.Endpoint,
      # Start the telemetry system
      Web.Telemetry,
      # Start the character workers supervisor
      %{
        id: Characters.Supervisor,
        start: {Characters.Supervisor, :start_link, [[]]}
      },
      # Start the Discord consumer
      Discord
    ]

    children =
      case Mix.env() do
        :test -> children
        _ -> children ++ [CharacterWorkers]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
