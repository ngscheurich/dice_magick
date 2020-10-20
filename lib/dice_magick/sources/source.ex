defmodule DiceMagick.Sources.Source do
  @moduledoc """
  Defines a `Behaviour` which clients that retrieve `DiceMagick.Rolls.Roll`
  should implement.
  """

  @type data_response :: {:ok, map() | struct()} | {:error, any}

  @callback validate_params(map) :: :ok | {:error, [String.t()]}
  @callback fetch_data(map()) :: data_response()
  @callback generate_rolls(data_response()) :: {:ok, [Rolls.Roll.t()]} | {:error, any}
end
