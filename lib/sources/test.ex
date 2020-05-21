defmodule Sources.Test do
  @moduledoc false

  @behaviour Sources.Source

  @impl true
  def validate_params(params) do
    case Map.get(params, "test") do
      nil -> {:error, "Must include test param"}
      _ -> :ok
    end
  end

  @impl true
  def fetch_data(_params), do: %{}

  @impl true
  def generate_rolls(_data), do: []
end
