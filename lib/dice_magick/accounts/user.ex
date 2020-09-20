defmodule DiceMagick.Accounts.User do
  @moduledoc """
  A user of the application.

  ## Fields

  * `nickname` - How the `User` should be identified in the app UI
  * `image` - An profile image
  * `discord_uid` - Identifies the `User` in the context of Discord

  ## Associations

  * `characters` - The `DiceMagick.Characters.Character`s that belong to this `User`

  ## Validations

  * `nickname` - Required
  * `discord_uid` - Required, unique

  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias DiceMagick.Characters.Character

  schema "users" do
    field :nickname, :string
    field :image, :string
    field :discord_uid, :string

    has_many :characters, Character

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :image, :discord_uid])
    |> validate_required([:nickname, :discord_uid])
    |> unique_constraint(:discord_uid, name: "users_discord_uid_index")
  end
end
