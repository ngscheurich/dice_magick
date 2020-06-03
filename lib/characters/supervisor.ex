defmodule Characters.Supervisor do
  @moduledoc """
  Supervises `Characters.CharacterWorker`s.
  """

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec add_worker(Ecto.UUID.t()) :: :ok | :noop
  def add_worker(id) do
    worker_name = Characters.Worker.name(id)

    case GenServer.whereis(worker_name) do
      nil ->
        child_spec = {Characters.Worker, character_id: id}
        DynamicSupervisor.start_child(__MODULE__, child_spec)

      _ ->
        :noop
    end
  end

  def ensure_started(id), do: add_worker(id)
end
