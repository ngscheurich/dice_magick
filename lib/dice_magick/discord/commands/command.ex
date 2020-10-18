defmodule DiceMagick.Discord.Command do
  @moduledoc """
  Defines a `Behaviour` that Discord command modules should implement.
  """

  @type command_result :: {:ok, String.t()} | {:error, String.t()}

  @callback execute([any], Nostrum.Struct.Message.t()) :: command_result
end
