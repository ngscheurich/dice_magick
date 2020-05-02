defmodule DiceMagick.Rolls.Roll do
  @moduledoc """
  [todo] Write documentation
  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias DiceMagick.Characters.Character

  @type part() :: [integer()]

  schema "rolls" do
    field :name, :string
    belongs_to :character, Character

    embeds_many :parts, Part do
      field :num, :integer
      field :die, :integer
      field :mod, :integer
    end

    timestamps()
  end

  @doc false
  def changeset(%Roll{} = roll, params) do
    roll
    |> cast(params, ~w(name character_id)a)
    |> cast_embed(:parts, with: &parts_changeset/2, required: true)
    |> validate_required(~w(name character_id)a)
  end

  defp parts_changeset(%Roll.Part{} = parts, params) do
    parts
    |> cast(params, ~w(num die mod)a)
    |> validate_required(~w(num die mod)a)
  end
end
