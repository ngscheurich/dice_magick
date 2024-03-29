defmodule DiceMagick.Rolls.Result do
  @moduledoc """
  The outcome of a `DiceMagick.Rolls.Roll` being evaluated.

  ## Fields

  * `name` - The name of the `Roll`
  * `expressions` - The dice expression that was evaluated
  * `total` - The outcome of evaluating the `expression`
  * `faces` - A list of die faces that were selected
  * `tags` - A list of tags attached to the `Roll`
  * `metadata` - The JSON metadata attached to the `Roll`

  ## Associations

  * `character` - The `DiceMagick.Characters.Character` the `Roll` belongs to

  ## Validations

  * `expression` - Required, must be valid
  * `total` - Required
  * `character_id` - Required
  * `character` - Must exist

  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ecto.Changeset

  schema "roll_results" do
    field(:name, :string)
    field(:expression, :string)
    field(:total, :integer)
    field(:faces, {:array, :integer}, default: [])
    field(:favorite, :boolean, default: false)
    field(:tags, {:array, :string}, default: [])
    field(:metadata, :map)

    belongs_to(:character, DiceMagick.Characters.Character)

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(%Result{} = result, params) do
    result
    |> cast(params, [
      :name,
      :expression,
      :total,
      :faces,
      :favorite,
      :tags,
      :metadata,
      :character_id
    ])
    |> validate_required([:expression, :total, :character_id])
    |> validate_expression()
    |> assoc_constraint(:character)
  end

  @spec validate_expression(Changeset.t()) :: Changeset.t()
  defp validate_expression(%Changeset{changes: %{expression: expression}} = chset) do
    if DiceMagick.Dice.valid_expression?(expression) do
      chset
    else
      add_error(chset, :expression, "Invalid expression")
    end
  end

  defp validate_expression(%Changeset{} = chset), do: chset
end
