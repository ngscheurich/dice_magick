defmodule DiceMagick.Discord.Server do
  @moduledoc """
  A `GenServer` that receives and responds to Discord messages.
  """

  use Nostrum.Consumer

  alias DiceMagick.Discord
  alias Discord.Commands
  alias Nostrum.Api, as: DiscordAPI

  @prefix "!"

  def start_link, do: Consumer.start_link(__MODULE__)

  # [todo] Consider using non-bang versions of API functions?

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: @prefix <> "create " <> input} = msg, _ws}) do
    {_, message} = Commands.Create.execute([input], msg)
    DiscordAPI.create_message!(msg.channel_id, message)
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: @prefix <> "roll " <> input} = msg, _ws}) do
    {_, message} = Commands.Roll.execute([input], msg)
    DiscordAPI.create_message!(msg.channel_id, message)
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: @prefix <> "sync"} = msg, _ws}) do
    {_, message} = Commands.Sync.execute([], msg)
    Discord.send_dm!(msg.author.id, message)
  end
end
