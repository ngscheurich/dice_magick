defmodule DiceMagick.Characters.Character do
  @moduledoc """
  A `DiceMagick.Accounts.User`’s character.

  [todo] Write better documentation.
  """

  use DiceMagick.Schema
  import Ecto.Changeset

  alias DiceMagick.Accounts.User
  alias Ecto.Changeset

  schema "characters" do
    field :name, :string
    field :source_type, SourceTypeEnum
    field :source_params, :map
    field :discord_channel_id, :string

    belongs_to :user, User

    has_many :roll_results, DiceMagick.Rolls.Result

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = character, params) do
    character
    |> cast(params, [:name, :source_type, :source_params, :discord_channel_id, :user_id])
    |> validate_required([:name, :discord_channel_id, :user_id])
    |> validate_source_params()
    |> assoc_constraint(:user)
    |> unique_constraint([:discord_channel_id, :user_id])
    |> unique_constraint([:name, :user_id])
  end

  @spec validate_source_params(Changeset.t()) :: Changeset.t()
  defp validate_source_params(%Changeset{changes: %{source_params: params}} = chset) do
    module =
      chset
      |> Changeset.get_field(:source_type)
      |> DiceMagick.Characters.source_for_type()

    case module.validate_params(params) do
      :ok -> chset
      {:error, errors} -> Enum.reduce(errors, chset, &add_error(&2, :source_params, &1))
    end
  end

  defp validate_source_params(%Changeset{} = chset), do: chset
end
