defmodule Characters.Worker do
  @moduledoc """
  Client/server for fetching and updating a `Characters.Character`'s `Rolls.Roll`s.
  """

  use GenServer
  require Logger
  alias Characters
  alias Characters.Character

  # @update_time 60_000

  defmodule State do
    @moduledoc """
    State for a character process.
    """

    @type t :: %__MODULE__{}
    defstruct [
      :character,
      :source_module,
      :source_type,
      :last_updated,
      source_params: %{},
      source_data: %{}
    ]
  end

  @doc """
  Starts a new worker for the given `Characters.Character`.
  """
  def start_link(%Character{id: id}) do
    GenServer.start_link(__MODULE__, id, name: name(id))
  end

  @doc """
  Returns the name of the registered process for the given `id`.
  """
  def name(id), do: {:global, {__MODULE__, id}}

  # defp schedule_update(time), do: Process.send_after(self(), :update, time)

  # ----------------------------------------------------------------------------
  # Client
  # ----------------------------------------------------------------------------

  @doc """
  Returns the state of the process.
  """
  def state(%Character{id: id}), do: GenServer.call(name(id), :state)

  @doc """
  Fetches new data from the character's `source`, and updates that character's `Rolls.Roll`s.
  """
  def update(%Character{id: id}), do: GenServer.cast(name(id), :update)

  # ----------------------------------------------------------------------------
  # Callbacks
  # ----------------------------------------------------------------------------

  @impl true
  def init(character_id) do
    character = Characters.get_character!(character_id, preload: [:rolls])
    %{source_type: type, source_params: params} = character

    state = %State{
      character: character,
      source_module: Characters.source_for_type(type),
      source_type: type,
      source_params: params,
      source_data: %{}
    }

    Process.send(self(), :update, [])

    Logger.log(:info, "Initialized process for #{character.name}")

    {:ok, state}
  end

  @impl true
  def handle_call(:state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_cast(:update, state) do
    Process.send(self(), :update, [])
    {:noreply, state}
  end

  @impl true
  def handle_info(:update, state) do
    %{character: character, source_module: module, source_params: params} = state
    {:ok, fresh_data} = module.fetch_data(params)
    {:ok, rolls} = module.generate_rolls(fresh_data)

    rolls =
      Enum.map(rolls, fn roll ->
        roll
        |> Map.delete(:tags)
        |> Map.put(:character_id, character.id)
      end)

    Characters.update_character(character, %{rolls: rolls})
    new_state = %{state | source_data: fresh_data, last_updated: DateTime.utc_now()}

    Logger.log(:info, "Updated rolls for #{character.name}")

    # schedule_update(@update_time)

    {:noreply, new_state}
  end
end
