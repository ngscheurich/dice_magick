defmodule DiceMagick.Characters.Character do
  @moduledoc """
  A user’s character.
  """

  use DiceMagick.Schema
  import Ecto.Changeset
  alias DiceMagick.Accounts.User

  schema "characters" do
    field :name, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
