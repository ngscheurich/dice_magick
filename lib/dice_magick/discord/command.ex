defmodule DiceMagick.Discord.Command do
  @moduledoc """
  [todo] Write documentation.
  """

  @type command_result :: {:ok, String.t()} | {:error, String.t()}

  @callback process([any], Nostrum.Struct.Message.t()) :: command_result
  @callback process([any], Nostrum.Struct.Message.t(), Keyword.t()) :: command_result
end
