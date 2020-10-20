defmodule DiceMagick.GoogleSheets.HTTPClient do
  @moduledoc """
  Functions for getting data from Google Sheets via HTTP.
  """

  def fetch_data(%{key: key, worksheet: worksheet}) do
    url = "https://spreadsheets.google.com/feeds/list/#{key}/#{worksheet}/public/full?alt=json"

    with {:ok, response} <- HTTPoison.get(url),
         {:ok, body} <- Jason.decode(response.body),
         do: {:ok, body}
  end

  def fetch_data(%{"key" => key, "worksheet" => worksheet}),
    do: fetch_data(%{key: key, worksheet: worksheet})
end
