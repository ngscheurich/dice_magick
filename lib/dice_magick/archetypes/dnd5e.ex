defmodule DiceMagick.Archetypes.DND5E do
  @moduledoc """
  An archetype representing a Dungeons & Dragons Fifth Edition character,
  including Proficiency Bonus, Ability Scores, Saving Throws, and Skills
  (natural skills and tools).
  """

  @behaviour DiceMagick.Archetype

  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__.{SavingThrow, Skill}

  @abilities [
    :strength,
    :dexterity,
    :constitution,
    :intelligence,
    :wisdom,
    :charisma
  ]

  @saving_throws [
    :strength_save,
    :dexterity_save,
    :constitution_save,
    :intelligence_save,
    :wisdom_save,
    :charisma_save
  ]

  @skills [
    :acrobatics,
    :animal_handling,
    :arcana,
    :athletics,
    :deception,
    :history,
    :insight,
    :intimidation,
    :investigation,
    :medicine,
    :nature,
    :perception,
    :performance,
    :persuasion,
    :religion,
    :sleight_of_hand,
    :stealth,
    :survival,
    :thieves_tools
  ]

  embedded_schema do
    field :proficiency_bonus, :integer

    # Ability Scores
    field :strength, :integer
    field :dexterity, :integer
    field :constitution, :integer
    field :intelligence, :integer
    field :wisdom, :integer
    field :charisma, :integer

    # Saving Throws
    embeds_one :strength_save, SavingThrow
    embeds_one :dexterity_save, SavingThrow
    embeds_one :constitution_save, SavingThrow
    embeds_one :intelligence_save, SavingThrow
    embeds_one :wisdom_save, SavingThrow
    embeds_one :charisma_save, SavingThrow

    # Skills
    embeds_one :acrobatics, Skill
    embeds_one :animal_handling, Skill
    embeds_one :arcana, Skill
    embeds_one :athletics, Skill
    embeds_one :deception, Skill
    embeds_one :history, Skill
    embeds_one :insight, Skill
    embeds_one :intimidation, Skill
    embeds_one :investigation, Skill
    embeds_one :medicine, Skill
    embeds_one :nature, Skill
    embeds_one :perception, Skill
    embeds_one :performance, Skill
    embeds_one :persuasion, Skill
    embeds_one :religion, Skill
    embeds_one :sleight_of_hand, Skill
    embeds_one :stealth, Skill
    embeds_one :survival, Skill
    embeds_one :thieves_tools, Skill
  end

  defmodule SavingThrow do
    use Ecto.Schema

    embedded_schema do
      field :ability, :string
      field :proficiency?, :boolean
    end

    @doc false
    def changeset(schema, params) do
      schema
      |> cast(params, [:ability, :proficiency?])
      |> validate_required([:ability, :proficiency?])
      |> validate_inclusion(:ability, :abilities)
    end
  end

  defmodule Skill do
    use Ecto.Schema

    embedded_schema do
      field :ability, :string
      field :proficiency?, :boolean
      field :expertise?, :boolean
    end

    @doc false
    def changeset(schema, params) do
      schema
      |> cast(params, [:ability, :proficiency?, :expertise?])
      |> validate_required([:ability, :proficiency?, :expertise?])
      |> validate_inclusion(:ability, :abilities)
    end
  end

  @doc false
  def changeset(schema, params) do
    schema
    |> cast(params, [:proficiency_bonus] ++ @abilities)
    |> validate_required([:proficiency_bonus] ++ @abilities)
    |> validate_inclusion(:proficiency_bonus, 2..6)
    |> validate_ability_scores()
    |> cast_saving_throws()
    |> cast_skills()
  end

  @spec validate_ability_scores(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_ability_scores(changeset) do
    Enum.reduce(@abilities, changeset, &validate_inclusion(&2, &1, 1..30))
  end

  @spec cast_saving_throws(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp cast_saving_throws(changeset) do
    Enum.reduce(@saving_throws, changeset, &cast_embed(&2, &1, required: true))
  end

  @spec cast_skills(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp cast_skills(changeset) do
    Enum.reduce(@skills, changeset, &cast_embed(&2, &1, required: true))
  end

  @impl true
  def name, do: :dnd5e

  @impl true
  def encode(stats) do
    case changeset(%__MODULE__{}, stats) do
      %{valid?: true, changes: changes} -> {:ok, changes}
      %{valid?: false, errors: errors} -> {:error, errors}
    end
  end
end
