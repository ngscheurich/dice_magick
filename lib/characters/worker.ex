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
      :character_id,
      :last_updated,
      rolls: [],
      tags: []
    ]
  end

  @doc """
  Starts a new worker for the given `Characters.Character`.
  """
  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: name(id))
  end

  # ----------------------------------------------------------------------------
  # Client
  # ----------------------------------------------------------------------------

  @doc """
  Returns the state of the process.
  """
  @spec state(String.t()) :: State
  def state(id), do: GenServer.call(name(id), :state)

  @doc """
  Fetches new data from the character's `source`, and updates that character's `Rolls.Roll`s.
  """
  @spec update(String.t()) :: :ok
  def update(id), do: GenServer.cast(name(id), :update)

  @doc """
  Similar to `update/1`, but performs the task synchronously.
  """
  @spec update_sync(String.t()) :: State
  def update_sync(id), do: GenServer.call(name(id), :update)

  @doc """
  Stops a character worker process.
  """
  @spec stop(String.t()) :: :ok
  def stop(id), do: GenServer.cast(name(id), :stop)

  # ----------------------------------------------------------------------------
  # Callbacks
  # ----------------------------------------------------------------------------

  @impl true
  def init(character_id) do
    state = %State{character_id: character_id}

    Logger.log(:info, "Initialized process for Character #{character_id}")

    Process.send(self(), :update, [])
    {:ok, state}
  end

  @impl true
  def handle_call(:state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_call(:update, _from, state) do
    new_state = update_state(state)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_cast(:update, state) do
    Process.send(self(), :update, [])
    {:noreply, state}
  end

  @impl true
  def handle_cast(:stop, state), do: {:stop, :normal, state}

  @impl true
  def handle_info(:update, state) do
    new_state = update_state(state)
    # schedule_update(@update_time)
    {:noreply, new_state}
  end

  # ----------------------------------------------------------------------------
  # Helpers
  # ----------------------------------------------------------------------------

  @doc """
  Returns the name of the registered process for the given `id`.
  """
  def name(id), do: {:global, {__MODULE__, id}}

  # defp schedule_update(time), do: Process.send_after(self(), :update, time)

  @spec update_state(State.t()) :: State.t()
  def update_state(%{character_id: character_id} = state) do
    character = Characters.get_character!(character_id, preload: [:rolls])
    module = Characters.source_for_type(character.source_type)

    {:ok, data} = module.fetch_data(character.source_params)
    {:ok, generated} = module.generate_rolls(data)

    # [todo] Compare each roll, only insert when needed
    rolls = Enum.map(generated, &Map.put(&1, :character_id, character.id))
    tags = tags_from_rolls(rolls)

    character =
      if rolls == rolls_for_match(character) do
        character
      else
        {:ok, character} = Characters.update_character(character, %{rolls: rolls})
        character
      end

    %{state | rolls: character.rolls, tags: tags, last_updated: DateTime.utc_now()}
  end

  @spec tags_from_rolls([map]) :: [String.t()]
  defp tags_from_rolls(rolls) do
    rolls
    |> Enum.flat_map(& &1.tags)
    |> Enum.uniq()
  end

  @spec rolls_for_match(Character.t()) :: [map]
  defp rolls_for_match(%Character{id: character_id, rolls: rolls}) do
    Enum.map(
      rolls,
      &%{
        character_id: character_id,
        expression: &1.expression,
        favorite: &1.favorite,
        metadata: &1.metadata,
        name: &1.name,
        tags: &1.tags
      }
    )
  end
end
