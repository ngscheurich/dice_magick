defmodule Taxonomy.Tag do
  @moduledoc """
  [todo] Write documentation
  """

  use Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Characters.Character
  alias Rolls.Roll
  alias Taxonomy.RollTag

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
