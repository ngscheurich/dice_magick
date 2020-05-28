defmodule Rolls.Result do
  @moduledoc """
  [todo] Write documentation
  """

  use Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Characters.Character
  alias Ecto.Changeset

  schema "roll_results" do
    field :name, :string
    field :expression, :string
    field :metadata, :map
    field :favorite, :boolean, default: false
    field :tags, {:array, :string}, default: []
    field :outcome, :integer

    belongs_to :character, Character

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(%Result{} = result, params) do
    result
    |> cast(params, [
      :name,
      :expression,
      :metadata,
      :favorite,
      :tags,
      :outcome,
      :character_id
    ])
    |> validate_required([:name, :expression, :outcome, :character_id])
    |> validate_expression()
    |> assoc_constraint(:character)
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
