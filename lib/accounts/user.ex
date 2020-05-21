defmodule Accounts.User do
  @moduledoc """
  A user of the application.
  """

  use Schema
  import Ecto.Changeset

  alias Characters.Character

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
