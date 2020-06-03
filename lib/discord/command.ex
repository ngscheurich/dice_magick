defmodule Discord.Command do
  @moduledoc """
  [todo] Write documentation.
  """

  @callback process([any()], Nostrum.Struct.Message.t()) ::
              {:ok, String.t()} | {:error, String.t()}
end
