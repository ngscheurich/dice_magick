defmodule DiceMagick.Sources.Test do
  @moduledoc false

  @behaviour DiceMagick.Sources.Source

  @impl true
  def validate_params(params) do
    case Map.get(params, "test") do
      nil -> {:error, "Must include test param"}
      _ -> :ok
    end
  end
end
