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
  alias DiceMagick.Rolls.Roll

  schema "characters" do
    field :name, :string
    belongs_to :user, User
    has_many :rolls, Roll

    timestamps()
  end

  @doc false
  def changeset(user, params) do
    user
    |> cast(params, [:name, :user_id])
    |> cast_assoc(:rolls, with: &Roll.changeset/2, on_replace: :delete)
    |> validate_required([:name, :user_id])
    |> assoc_constraint(:user)
  end
end
