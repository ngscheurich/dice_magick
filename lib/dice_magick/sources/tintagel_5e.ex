defmodule DiceMagick.Sources.Tintagel5E do
  @moduledoc """
  [todo] Add documentation.

  ## Params

    * `key` - The key of the Google Sheets spreadsheet to retrieve

  ## Examples

      %{key: "1sEEi3cUfUqc-suoKGPhMQ0eh7KCPbn3ksgOZ-b5q3QI"}

  """

  @behaviour DiceMagick.Sources.Source

  alias DiceMagick.Rolls.Roll
  alias GoogleApi.Sheets.V4, as: Sheets

  @impl true
  def validate_params(%{key: _}), do: :ok
  def validate_params(_params), do: {:error, ["must include key param"]}

  @impl true
  def fetch_data(%{"key" => id}) do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/spreadsheets")
    client = Sheets.Connection.new(token.token)
    get_spreadsheet_data(client, id)
  end

  @spec get_spreadsheet_data(Tesla.Client.t(), String.t()) ::
          DiceMagick.Sources.Source.data_response()
  defp get_spreadsheet_data(client, id) do
    ranges = [
      # Ability Scores
      "Front!I9:K14",

      # Saving Throws
      "Front!N9:W14",

      # Skills
      "Front!B20:O37",

      # Weapons and Spells
      "Front!V29:BM34"
    ]

    options = [includeGridData: true, ranges: ranges]
    Sheets.Api.Spreadsheets.sheets_spreadsheets_get(client, id, options)
  end

  @impl true
  def generate_rolls(%Sheets.Model.Spreadsheet{} = data) do
    [sheet] = data.sheets
    [abilities, saves, skills, _attacks] = sheet.data

    ability_rolls = ability_rolls(abilities)
    save_rolls = save_rolls(saves)
    skill_rolls = skill_rolls(skills)

    {:ok, ability_rolls ++ save_rolls ++ skill_rolls}
  end

  @spec ability_rolls(Sheets.Model.GridData.t()) :: [Roll.t()]
  defp ability_rolls(%Sheets.Model.GridData{} = data) do
    [str, dex, con, int, wis, cha] = formatted_values(data)

    [
      d20_roll(str, "STR Roll", ["str"], false),
      d20_roll(dex, "DEX Roll", ["dex"], false),
      d20_roll(con, "CON Roll", ["con"], false),
      d20_roll(int, "INT Roll", ["int"], false),
      d20_roll(wis, "WIS Roll", ["wis"], false),
      d20_roll(cha, "CHA Roll", ["cha"], false)
    ]
  end

  @spec save_rolls(Sheets.Model.GridData.t()) :: [Roll.t()]
  defp save_rolls(%Sheets.Model.GridData{rowData: rows}) do
    Enum.map(rows, fn %{values: cells} ->
      [a, _, _, _, b, _, _, c] = Enum.map(cells, & &1.formattedValue)
      name = "#{a} Save"
      mod = String.trim_trailing(b)
      tags = [String.downcase(a), "save"]

      d20_roll(mod, name, tags, !is_nil(c))
    end)
  end

  @spec skill_rolls(Sheets.Model.GridData.t()) :: [Roll.t()]
  defp skill_rolls(%Sheets.Model.GridData{rowData: rows}) do
    Enum.map(rows, fn %{values: cells} ->
      [a, _, _, b, _, _, _, _, _, _, _, _, c] = Enum.map(cells, & &1.formattedValue)

      mod = String.trim_trailing(a)
      [_, name, ability] = Regex.run(~r/([^)]*) \((.*)\)/, b)

      tags =
        case ability do
          "Cha" -> ["cha", "social"]
          val -> [String.downcase(val)]
        end

      d20_roll(mod, name, tags, !is_nil(c))
    end)
  end

  @spec d20_roll(String.t(), String.t(), [String.t()], boolean()) :: map()
  defp d20_roll(<<sign::bytes-size(1)>> <> num, name, tags, favorite) do
    %Roll{
      name: name,
      expression: "1d20 #{sign} #{num}",
      tags: tags,
      favorite: favorite
    }
  end

  @spec formatted_values(Sheets.Model.GridData.t()) :: [String.t()]
  defp formatted_values(%Sheets.Model.GridData{rowData: rows}) do
    Enum.flat_map(rows, fn %{values: values} ->
      Enum.map(values, &String.trim(&1.formattedValue))
    end)
  end

  @spec d20_rolls([{String.t(), String.t()}], [String.t()]) :: [Roll.t()]
  def d20_rolls(meta, mods), do: d20_rolls(meta, mods, [])

  @spec d20_rolls([{String.t(), String.t()}], [String.t()], [Roll.t()]) :: [Roll.t()]
  def d20_rolls([], [], rolls), do: rolls

  def d20_rolls([{name, tags} | meta], [mod | mods], rolls) do
    roll = %Roll{name: name, expression: "1d20 + #{mod}", tags: tags}
    d20_rolls(meta, mods, rolls ++ [roll])
  end
end
