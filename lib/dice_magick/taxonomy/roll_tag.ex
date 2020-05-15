defmodule DiceMagick.Taxonomy.RollTag do
  @moduledoc """
  [todo] Write documentation
  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias DiceMagick.Rolls.Roll
  alias DiceMagick.Taxonomy.Tag

  schema "roll_tags" do
    belongs_to :roll, Roll
    belongs_to :tag, Tag

    timestamps()
  end

  @doc false
  def changeset(%RollTag{} = roll_tag, params) do
    roll_tag
    |> cast(params, [:roll_id, :tag_id])
    |> validate_required([:roll_id, :tag_id])
    |> assoc_constraint(:roll)
    |> assoc_constraint(:tag)
    |> unique_constraint(:roll)
  end
end
