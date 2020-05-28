defmodule Sources.GoogleSheetsTest do
  use ExUnit.Case, async: true

  alias Sources.GoogleSheets

  test "fetch_data/1 with valid params returns data" do
    assert {:ok, _} = GoogleSheets.fetch_data(%{key: "abc123", worksheet: "1"})
  end

  test "fetch_data/1 with invalid params returns error" do
    assert {:error, _} = GoogleSheets.fetch_data(%{key: "123abc", worksheet: "2"})
  end

  test "validate_params/1 with valid params returns :ok" do
    assert GoogleSheets.validate_params(%{key: "", worksheet: ""}) == :ok
  end

  test "validate_params/1 with invalid params returns error" do
    assert GoogleSheets.validate_params(%{}) ==
             {:error, ["must include key param", "must include worksheet param"]}
  end

  test "generate_rolls/1 with valid data returns roll params" do
    {:ok, data} = GoogleSheets.fetch_data(%{key: "abc123", worksheet: "1"})

    assert GoogleSheets.generate_rolls(data) ==
             {:ok,
              [
                %Rolls.Roll{
                  name: "History",
                  expression: "1d20 + 5",
                  metadata: %{"proficiency" => "proficient"},
                  favorite: true,
                  tags: ["skill", "int"]
                }
              ]}
  end

  test "generate_rolls/1 with invalid data returns error" do
    assert GoogleSheets.generate_rolls(%{}) == {:error, :invalid_data}
  end
end
