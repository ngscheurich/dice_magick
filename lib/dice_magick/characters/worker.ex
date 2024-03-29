defmodule DiceMagick.Characters.Worker do
  @moduledoc """
  Client/server for fetching and updating a `DiceMagick.Characters.Character`'s
  `DiceMagick.Rolls.Roll`s.
  """

  use GenServer

  require Logger

  alias DiceMagick.Characters
  alias DiceMagick.Rolls.Roll
  alias Ecto.UUID

  defmodule State do
    @moduledoc """
    State for a worker process.
    """

    @type t() :: %__MODULE__{}
    defstruct [
      :character_id,
      :synced_at,
      rolls: [],
      tags: []
    ]
  end

  @doc """
  Starts a new worker process.

  ## Options

    * `character_id` - The UUID of the `DiceMagick.Characters.Character` (required)
    * `state` - The initial state for the worker

  """
  @spec start_link(Keyword.t()) :: :ignore | {:error, term} | {:ok, pid}
  def start_link(opts) do
    character_id = Keyword.fetch!(opts, :character_id)

    state_fields =
      opts
      |> Keyword.get(:state, %{})
      |> Map.put(:character_id, character_id)

    state = struct!(State, state_fields)

    GenServer.start_link(__MODULE__, state, name: name(character_id))
  end

  ## Client

  @doc """
  Returns the name of the registered process for the given `character_id`.
  """
  @spec name(UUID.t()) :: {:global, {atom(), UUID.t()}}
  def name(character_id), do: {:global, {__MODULE__, character_id}}

  @doc """
  Returns the state of the worker process.
  """
  @spec state(String.t()) :: State.t()
  def state(character_id) do
    Characters.Supervisor.ensure_started(character_id)
    GenServer.call(name(character_id), :state)
  end

  @doc """
  Fetches new data from the `DiceMagick.Characters.Character`'s `source`, and
  updates that character's `DiceMagick.Rolls.Roll`s.
  """
  @spec update(String.t()) :: :ok
  def update(character_id) do
    Characters.Supervisor.ensure_started(character_id)
    GenServer.cast(name(character_id), :update)
  end

  @doc """
  Similar to `update/1`, but performs the task synchronously.
  """
  @spec update_sync(String.t()) :: State.t()
  def update_sync(character_id) do
    Characters.Supervisor.ensure_started(character_id)
    GenServer.call(name(character_id), :update)
  end

  @doc """
  Stops a worker process.
  """
  @spec stop(String.t()) :: :ok
  def stop(character_id), do: GenServer.cast(name(character_id), :stop)

  ## Server callbacks

  @impl true
  def init(%{character_id: character_id} = state) do
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

  ## Helpers

  @spec update_state(State.t()) :: State.t()
  defp update_state(%{character_id: character_id} = state) do
    character = Characters.get_character!(character_id)

    case character.source_type do
      nil ->
        state

      type ->
        module = Characters.source_for_type(type)

        {:ok, data} = module.fetch_data(character.source_params)
        {:ok, rolls} = module.generate_rolls(data)
        rolls = Enum.map(rolls, &%Roll{&1 | character_id: character_id})

        tags = tags_from_rolls(rolls)

        %{state | rolls: rolls, tags: tags, synced_at: DateTime.utc_now()}
    end
  end

  @spec tags_from_rolls([Roll.t()]) :: [String.t()]
  defp tags_from_rolls(rolls) do
    rolls
    |> Enum.flat_map(& &1.tags)
    |> Enum.uniq()
  end
end
