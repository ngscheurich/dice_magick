defmodule DiceMagick.Discord do
  @moduledoc """
  [todo] Write documentation.
  """

  use Nostrum.Consumer

  alias __MODULE__
  alias Nostrum.Api, as: DiscordAPI

  @prefix "!"

  def start_link, do: Consumer.start_link(__MODULE__)

  # [todo] Consider using non-bang versions of API functions?

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: @prefix <> "create " <> name} = msg, _ws}) do
    {_, message} = Discord.Create.process([name], msg)
    DiscordAPI.create_message!(msg.channel_id, message)
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: @prefix <> "roll " <> input} = msg, _ws_state}) do
    {_, message} = Discord.Roll.process([input], msg)
    DiscordAPI.create_message!(msg.channel_id, message)
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: @prefix <> "sync"} = msg, _ws_state}) do
    {_, message} = Discord.Sync.process([], msg)
    send_dm!(msg.author.id, message)
  end

  def handle_event(_event), do: :noop

  @type opts() :: [{:roll_name, String.t()}]
  @spec roll_message(String.t(), String.t(), Integer.t(), opts()) :: String.t()
  @doc """
  [todo] Write documentation.
  """
  def roll_message(character_name, expression, outcome, opts \\ []) do
    info =
      case Keyword.get(opts, :roll_name) do
        nil -> "**#{character_name}** rolls `#{expression}`…"
        roll_name -> "**#{character_name}** rolls _#{roll_name}_ (`#{expression}`)…"
      end

    """
    #{info}
    :game_die: Result: **#{outcome}**
    """
  end

  @doc """
  [todo] Write documentation.
  """
  @spec send_message(Integer.t(), String.t()) :: {:ok, Nostrum.Struct.Message.t()} | any()
  def send_message(channel_id, message) do
    DiscordAPI.create_message(channel_id, message)
  end

  @doc """
  [todo] Write documentation.
  """
  @spec send_dm!(Integer.t(), String.t()) :: none
  def send_dm!(user_id, message) do
    %{id: channel_id} = DiscordAPI.create_dm!(user_id)
    DiscordAPI.create_message!(channel_id, message)
  end
end
