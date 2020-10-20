defmodule DiceMagick.Discord.Commands do
  @moduledoc """
  Context module for Discord bot commands.
  """

  alias __MODULE__

  defdelegate roll(input, msg), to: Commands.Roll, as: :execute
  defdelegate sync(input, msg), to: Commands.Sync, as: :execute
  defdelegate create(input, msg), to: Commands.Create, as: :execute
end
