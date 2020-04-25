defmodule DiceMagick.Characters.Character do
  @moduledoc """
  A user’s character. Has a stats field which can be encoded into a known game
  system's format by way of an archetype.
  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias DiceMagick.Accounts.User
  alias DiceMagick.Archetypes

  schema "characters" do
    field :name, :string
    field :archetype, CharacterArchetypeEnum, default: :custom
    field :stats, :map, default: %{}

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user, params) do
    user
    |> cast(params, [:name, :archetype, :stats, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_stats()
  end

  @spec validate_stats(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_stats(%Ecto.Changeset{} = changeset) do
    archetype = get_field(changeset, :archetype)
    stats = get_field(changeset, :stats)

    module = module_for_archetype(archetype)

    case module.encode(stats) do
      {:ok, _} ->
        changeset

      {:error, errors} ->
        changeset
        |> add_error(:stats, "Stats do not match archetype", errors)
        |> delete_change(:stats)
    end
  end

  @spec module_for_archetype(CharacterArchetypeEnum.t()) :: atom()
  defp module_for_archetype(:dnd5e), do: Archetypes.DND5E
  defp module_for_archetype(_), do: Archetypes.Custom
end
