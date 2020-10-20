defmodule DiceMagick.GoogleSheets.InMemory do
  @moduledoc """
  Functions that simulate getting data from Google Docs via HTTP.
  """

  def fetch_data(%{key: "abc123", worksheet: "1"}),
    do:
      {:ok,
       %{
         "feed" => %{
           "entry" => [
             %{
               "gsx$favorite" => %{
                 "$t" => "TRUE"
               },
               "gsx$metadata" => %{
                 "$t" => "{\"proficiency\": \"proficient\"}"
               },
               "gsx$name" => %{
                 "$t" => "History"
               },
               "gsx$expression" => %{
                 "$t" => "1d20 + 5"
               },
               "gsx$tags" => %{
                 "$t" => "skill, int"
               }
             }
           ]
         }
       }}

  def fetch_data(_params), do: {:error, :invalid_params}
end
