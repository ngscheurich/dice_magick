defmodule DiceMagick.Sources.Source do
  @moduledoc """
  [todo] Add documentation.
  """

  @type result() :: {:ok, [DiceMagick.Rolls.Roll.t()]} | {:error, any()}

  @callback validate_params(map()) :: :ok | {:error, String.t()}
  @callback fetch_data(map) :: {:ok, any()} | {:error, any()}
  @callback generate_rolls(map) :: result()
end
