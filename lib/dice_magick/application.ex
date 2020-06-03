defmodule DiceMagick.Application do
  @moduledoc false

  use Application
  alias DiceMagick.Characters

  defmodule CharacterWorkers do
    @moduledoc false

    use GenServer

    def start_link(_), do: GenServer.start_link(__MODULE__, :ok)

    @impl true
    def init(:ok) do
      Characters.Character
      |> DiceMagick.Repo.all()
      |> Enum.each(&Characters.Supervisor.add_worker(&1.id))

      :ignore
    end
  end

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      DiceMagick.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PubSub},
      # Start the endpoint when the application starts
      DiceMagickWeb.Endpoint,
      # Start the telemetry system
      DiceMagickWeb.Telemetry,
      # Start the character workers supervisor
      %{
        id: Characters.Supervisor,
        start: {Characters.Supervisor, :start_link, [[]]}
      },
      # Start the Discord consumer
      DiceMagick.Discord
    ]

    children =
      case Mix.env() do
        :test -> children
        _ -> children ++ [CharacterWorkers]
      end

    opts = [strategy: :one_for_one, name: Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DiceMagickWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
