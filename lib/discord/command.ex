defmodule Discord.Commands do
  @moduledoc """
  [todo] Write documentation.
  """

  @callback process([any()], Nostrum.Struct.Message.t()) ::
              {:ok, String.()} | {:error, String.t()}
end
