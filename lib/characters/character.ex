defmodule Characters.Character do
  @moduledoc """
  A `Accounts.User`’s character.

  ## Fields

  * `name` - A human-readable label
  * `user_id` - UUID identifying the owner

  ## Associations

  * `user` - `Accounts.User` that the character belongs to

  ## Validations

  * `name` - Required
  * `user_id` - Required
  * `user` - Must exist

  """

  use Schema
  import Ecto.Changeset

  alias Accounts.User
  alias Ecto.Changeset

  schema "characters" do
    field :name, :string
    field :source_type, SourceTypeEnum
    field :source_params, :map

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = character, params) do
    character
    |> cast(params, [:name, :source_type, :source_params, :user_id])
    |> validate_required([:name, :source_type, :source_params, :user_id])
    |> validate_source_params()
    |> assoc_constraint(:user)
  end

  @spec validate_source_params(Changeset.t()) :: Changeset.t()
  defp validate_source_params(%Changeset{changes: %{source_params: params}} = chset) do
    module =
      chset
      |> Changeset.get_field(:source_type)
      |> Characters.source_for_type()

    case module.validate_params(params) do
      :ok -> chset
      {:error, errors} -> Enum.reduce(errors, chset, &add_error(&2, :source_params, &1))
    end
  end

  defp validate_source_params(%Changeset{} = chset), do: chset
end
