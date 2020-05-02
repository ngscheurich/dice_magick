defmodule DiceMagick.Characters.Character do
  @moduledoc """
  A user’s character.
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
