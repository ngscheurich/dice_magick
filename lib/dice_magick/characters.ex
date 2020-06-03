defmodule DiceMagick.Characters do
  @moduledoc """
  The Characters context.
  """

  alias DiceMagick.{Characters, Repo, Sources}
  alias DiceMagick.Characters.Character
  alias DiceMagick.Accounts.User

  import Ecto.Query

  @type repo_result :: {:ok, Character.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of `DiceMagick.Characters.Character`s for a
  `DiceMagick.Accounts.User`.

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
  Gets a single `DiceMagick.Characters.Character`.

  Raises `Ecto.NoResultsError` if the `Character` does not exist.

  ## Options

    * `preload` - Specifies which associations, if any, to preload

  ## Examples

      iex> get_character!("123", preload: [:roll_results])
      %Character{}

      iex> get_character!("456")
      ** (Ecto.NoResultsError)

  """
  @spec get_character!(Ecto.UUID.t(), [{:preload, atom | [atom] | Keyword.t()}]) :: Character.t()
  def get_character!(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Character
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  @doc """
  Creates a `DiceMagick.Characters.Character`. On success, starts a new
  `DiceMagick.Characters.Worker` for the character.

  ## Examples

      iex> create_character(%{field: value})
      {:ok, %Character{}}

      iex> create_character(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_character(map) :: repo_result
  def create_character(attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a `DiceMagick.Characters.Character`.

  ## Examples

      iex> update_character(character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_character(Character.t(), map) :: {:ok, Character.t()} | {:error, Changeset.t()}
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
    |> maybe_notify_worker(attrs)
  end

  @spec maybe_notify_worker(repo_result, map) :: repo_result
  defp maybe_notify_worker({:ok, character} = result, %{source_params: _}) do
    Characters.Worker.update(character.id)
    result
  end

  defp maybe_notify_worker(result, _attrs), do: result

  @doc """
  Deletes a `DiceMagick.Characters.Character`.

  ## Examples

      iex> delete_character(character)
      {:ok, %Character{}}

      iex> delete_character(character)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_character(Character.t()) :: {:ok, Character.t()} | {:error, Changeset.t()}
  def delete_character(%Character{} = character), do: Repo.delete(character)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking `DiceMagick.Characters.Character`
  changes.

  ## Examples

      iex> change_character(character)
      %Ecto.Changeset{data: %Character{}}

  """
  @spec change_character(Character.t(), map) :: Changeset.t()
  def change_character(%Character{} = character, attrs \\ %{}) do
    Character.changeset(character, attrs)
  end

  @doc """
  Given a `SourceTypeEnum`, returns the module for that type.
  """
  @spec source_for_type(atom) :: atom
  def source_for_type(:test), do: Sources.Test
  def source_for_type(:google_sheets), do: Sources.GoogleSheets

  @doc """
  Gets the `DiceMagick.Characters.Character` for the given `discord_uid` and
  `discord_channel_id`.

  Returns `nil` if no such `Character` is found.

  ## Examples

      iex> get_character_for_channel("123456", "7890101")
      %Character{}

      iex> get_character_for_channel("654321", "7890101")
      nil

  """
  @spec get_character_for_channel(String.t(), String.t()) :: Character.t() | nil
  def get_character_for_channel(discord_uid, discord_channel_id) do
    query =
      from c in Character,
        join: u in User,
        on: u.discord_uid == ^discord_uid,
        where: c.discord_channel_id == ^discord_channel_id,
        limit: 1

    Repo.one(query)
  end
end
