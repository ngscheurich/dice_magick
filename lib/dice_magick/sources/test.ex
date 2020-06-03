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

  @impl true
  def fetch_data(_params), do: {:ok, %{}}

  @impl true
  def generate_rolls(_data), do: {:ok, []}
end
