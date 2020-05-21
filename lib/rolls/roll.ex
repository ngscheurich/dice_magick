defmodule Rolls.Roll do
  @moduledoc """
  [todo] Write documentation
  """

  use Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Characters.Character
  alias Taxonomy.{Tag, RollTag}
  alias Ecto.Changeset

  @type part() :: [integer()]

  schema "rolls" do
    field :name, :string
    field :expression, :string
    field :metadata, :map
    field :favorite, :boolean, default: false

    belongs_to :character, Character

    many_to_many :tags, Tag, join_through: RollTag

    timestamps()
  end

  @doc false
  def changeset(%Roll{} = roll, params) do
    roll
    |> cast(params, [:name, :expression, :metadata, :favorite, :character_id])
    |> cast_assoc(:tags)
    |> validate_required([:name, :expression, :character_id])
    |> validate_expression()
    |> assoc_constraint(:character)
    |> unique_constraint(:name)
  end

  @spec validate_expression(Changeset.t()) :: Changeset.t()
  defp validate_expression(%Changeset{changes: %{expression: expression}} = chset) do
    case ExDiceRoller.compile(expression) do
      {:ok, _} -> chset
      {:error, _} -> add_error(chset, :expression, "Token parsing failed")
    end
  end

  defp validate_expression(%Changeset{} = chset), do: chset
end