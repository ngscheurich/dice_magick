defmodule DiceMagick.Taxonomy.Tag do
  @moduledoc """
  [todo] Write documentation
  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias DiceMagick.Characters.Character
  alias DiceMagick.Rolls.Roll
  alias DiceMagick.Taxonomy.RollTag

  schema "tags" do
    field :name, :string

    belongs_to :character, Character

    many_to_many :rolls, Roll, join_through: RollTag

    timestamps()
  end

  @doc false
  def changeset(%Tag{} = tag, params) do
    tag
    |> cast(params, [:name, :character_id])
    |> validate_required([:name, :character_id])
    |> assoc_constraint(:character)
    |> unique_constraint(:name)
  end
end
