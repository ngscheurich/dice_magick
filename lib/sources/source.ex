defmodule Sources.Source do
  @moduledoc """
  [todo] Add documentation.
  """

  @type data_response :: {:ok, map()} | {:error, any()}
  @type roll_params() :: %{
          required(:name) => String.t(),
          required(:expression) => String.t(),
          optional(:metadata) => map(),
          optional(:favorite) => boolean(),
          optional(:tags) => any()
        }
  @type result() :: {:ok, [roll_params()]} | {:error, any()}

  @callback validate_params(map()) :: :ok | {:error, [String.t()]}
  @callback fetch_data(map()) :: data_response()
  @callback generate_rolls(data_response()) :: result()
end
