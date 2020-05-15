defmodule DiceMagick.Rolls.Roll do
  @moduledoc """
  [todo] Write documentation
  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias DiceMagick.Characters.Character
  alias DiceMagick.Taxonomy.RollTag

  @type part() :: [integer()]

  schema "rolls" do
    field :name, :string

    belongs_to :character, Character

    many_to_many :tags, Roll, join_through: RollTag

    embeds_many :parts, Part do
      field :num, :integer
      field :sides, :integer
      field :mod, :integer
    end

    timestamps()
  end

  @doc false
  def changeset(%Roll{} = roll, params) do
    roll
    |> cast(params, [:name, :character_id])
    |> cast_embed(:parts, with: &parts_changeset/2, required: true)
    |> validate_required([:name, :character_id])
    |> assoc_constraint(:character)
    |> unique_constraint(:name)
  end

  defp parts_changeset(%Roll.Part{} = parts, params) do
    parts
    |> cast(params, ~w(num sides mod)a)
    |> validate_required(~w(num sides mod)a)
  end
end
