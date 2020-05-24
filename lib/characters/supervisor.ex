defmodule Characters.Supervisor do
  @moduledoc """
  Supervises `Characters.CharacterWorker`s.
  """

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_worker(id) do
    worker_name = Characters.Worker.name(id)

    case GenServer.whereis(worker_name) do
      nil ->
        child_spec = {Characters.Worker, id}
        DynamicSupervisor.start_child(__MODULE__, child_spec)

      _ ->
        :noop
    end
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
