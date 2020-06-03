defmodule DiceMagick.Discord do
  @moduledoc """
  [todo] Write documentation.
  """

  use Nostrum.Consumer

  alias DiceMagick.Discord.Commands
  alias Nostrum.Api, as: DiscordAPI

  def start_link, do: Consumer.start_link(__MODULE__)

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: "!dm create " <> name} = msg, _ws}) do
    {_, message} = Commands.Create.process([name], msg)
    DiscordAPI.create_message(msg.channel_id, message)
  end

  def handle_event({:MESSAGE_CREATE, %{content: "!dm roll " <> input} = msg, _ws_state}) do
    {_, message} = Commands.Roll.process([input], msg)
    DiscordAPI.create_message(msg.channel_id, message)
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
  def send_message(channel_id, message), do: DiscordAPI.create_message(channel_id, message)
end
