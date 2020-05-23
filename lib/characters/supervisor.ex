defmodule Characters.Supervisor do
  @moduledoc """
  Supervises `Characters.CharacterWorker`s.
  """

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_worker(%Characters.Character{} = character) do
    child_spec = {Characters.Worker, character}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
