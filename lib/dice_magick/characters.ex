defmodule DiceMagick.Characters do
  @moduledoc """
  The Characters context.
  """

  alias DiceMagick.Characters.Character
  alias DiceMagick.Accounts.User
  alias DiceMagick.Repo
  alias Ecto.Changeset

  import Ecto.Query

  @doc """
  Returns the list of `Character`s for a `User`.

  ## Examples

      iex> list_characters_for_user(user)
      [%Character{}, ...]

  """
  @spec list_characters_for_user(User.t()) :: [Character.t()]
  def list_characters_for_user(%User{id: user_id}) do
    Character
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single `Character`.

  Raises `Ecto.NoResultsError` if the `Character` does not exist.

  ## Examples

      iex> get_character!("123")
      %Character{}

      iex> get_character!("456")
      ** (Ecto.NoResultsError)

  """
  @spec get_character!(Ecto.UUID.t()) :: Character.t()
  def get_character!(id), do: Repo.get!(Character, id)

  @doc """
  Creates a `Character`.

  ## Examples

      iex> create_character(%{field: value})
      {:ok, %Character{}}

      iex> create_character(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_character(map()) :: {:ok, Character.t()} | {:error, Changeset.t()}
  def create_character(attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a `Character`.

  ## Examples

      iex> update_character(character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_character(Character.t(), map()) :: {:ok, Character.t()} | {:error, Changeset.t()}
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a `Character`.

  ## Examples

      iex> delete_character(character)
      {:ok, %Character{}}

      iex> delete_character(character)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_character(Character.t()) :: {:ok, Character.t()} | {:error, Changeset.t()}
  def delete_character(%Character{} = character), do: Repo.delete(character)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking `Character` changes.

  ## Examples

      iex> change_character(character)
      %Ecto.Changeset{data: %Character{}}

  """
  @spec change_character(Character.t(), map()) :: Changeset.t()
  def change_character(%Character{} = character, attrs \\ %{}) do
    Character.changeset(character, attrs)
  end
end
