defmodule DiceMagick.Sources.Source do
  @moduledoc """
  [todo] Add documentation.
  """

  @type data_response :: {:ok, map} | {:error, any}

  @callback validate_params(map) :: :ok | {:error, [String.t]}
  @callback fetch_data(map) :: data_response
  @callback generate_rolls(data_response) :: {:ok, [Rolls.Roll.t]} | {:error, any}
end
