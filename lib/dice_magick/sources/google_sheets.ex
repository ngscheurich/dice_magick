defmodule DiceMagick.Sources.GoogleSheets do
  @moduledoc """
  [todo] Add documentation.

  ## Params

  * `sheet_id` - The ID of the Google Sheets doc

  """

  @behaviour DiceMagick.Sources.Source

  @impl true
  def validate_params(params) do
    case Map.get(params, "sheet_id") do
      nil -> {:error, "Must include sheet_id param"}
      _ -> :ok
    end
  end
end
