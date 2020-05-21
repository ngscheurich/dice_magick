defmodule Rolls do
  @moduledoc """
  [todo] Write documentation
  """

  alias Rolls.{Roll, Encoders}
  alias Repo

  @doc """
  Translates the given `data` into a list of `Roll`s.

  ## Options

  * `format` - Specifies the format of the incoming data. Defaults to `:csv`.

  ## Examples

      iex> encode_rolls(~s(Cursed Greatsword,"1d10 - 1"))
      %Roll{name: "Cursed Greatsword", parts: [{1, 10, -1}]}

      iex> encode_rolls(~s(Wisdom Save,"1d20, 4")
      {:error, "Error message"}

  """
  @spec encode_rolls(any(), format: atom()) :: Sources.Source.parsed()
  def encode_rolls(data, opts \\ []) do
    module =
      opts
      |> Keyword.get(:format, :csv)
      |> module_for_format()

    module.encode(data)
  end

  @spec module_for_format(SourceEnum.t()) :: atom()
  defp module_for_format(:csv), do: Encoders.CSV

  @doc """
  Creates a `Roll`.

  ## Examples

      iex> create_roll(%{field: value})
      {:ok, %Roll{}}

      iex> create_roll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_roll(map()) :: {:ok, Roll.t()} | {:error, Changeset.t()}
  def create_roll(attrs \\ %{}) do
    %Roll{}
    |> Roll.changeset(attrs)
    |> Repo.insert()
  end
end
