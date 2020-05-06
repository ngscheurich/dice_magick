defmodule DiceMagick.Characters.Character do
  @moduledoc """
  A `DiceMagick.Accounts.User`’s character.

  ## Fields

  * `name` - A human-readable label
  * `user_id` - UUID identifying the owner

  ## Associations

  * `user` - `DiceMagick.Accounts.User` that the character belongs to
  * `rolls` - `DiceMagick.Rolls.Roll`s associated with this character

  ## Validations

  * `name` - Required
  * `user_id` - Required
  * `user` - Must exist

  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias DiceMagick.Accounts.User
  alias DiceMagick.Enums.DataFormatEnum
  alias DiceMagick.Rolls.{Roll, CSVEncoder}

  schema "characters" do
    field :name, :string

    field :roll_data, :string, virtual: true
    field :data_format, DataFormatEnum, virtual: true

    belongs_to :user, User
    has_many :rolls, Roll, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = character, params) do
    character
    |> cast(params, [:name, :user_id, :roll_data, :data_format])
    |> cast_assoc(:rolls, with: &Roll.changeset/2)
    |> assoc_constraint(:user)
    |> encode_rolls()
    |> case do
      %{action: :insert} = changeset ->
        validate_required(changeset, [:name, :user_id, :roll_data, :data_format])

      changeset ->
        validate_required(changeset, [:name, :user_id])
    end
  end

  @spec encode_rolls(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp encode_rolls(%Ecto.Changeset{changes: %{roll_data: data, data_format: format}} = changeset) do
    module = encoder_for_format(format)

    case module.encode(data) do
      {:ok, rolls} -> put_change(changeset, :rolls, rolls)
      {:error, error_msg} -> add_error(changeset, :roll_data, error_msg)
    end
  end

  defp encode_rolls(%Ecto.Changeset{} = chset), do: chset

  @spec encoder_for_format(atom()) :: atom()
  defp encoder_for_format(:csv), do: CSVEncoder
end
