defmodule DiceMagick.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias __MODULE__.User
  alias DiceMagick.Repo

  @doc """
  Gets a single `DiceMagick.Account.User`.

  Raises `Ecto.NoResultsError` if the `User` does not exist.

  ## Examples

      iex> get_user!("123")
      %User{}

      iex> get_user!("456")
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(String.t()) :: User.t()
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a `User`.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Given an `Ueberauth.Auth` struct, returns a `DiceMagick.Accounts.User`. If a
  `User` with the auth struct's `uid` already exists, it is returned. Otherwise
  a new `User` is created.

  ## Examples

      iex> find_or_create_user(auth)
      {:ok, %User{}}

      iex> find_or_create_user(auth)
      {:error, "Something went wrong"}

  """
  @spec find_or_create_user(Ueberauth.Auth.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create_user(%Ueberauth.Auth{uid: uid, info: info}) do
    case Repo.get_by(User, discord_uid: uid) do
      nil ->
        create_user(%{
          nickname: info.nickname,
          image: info.image,
          discord_uid: uid
        })

      user ->
        {:ok, user}
    end
  end

  @doc """
  Gets the `DiceMagick.Accounts.User` with the given `discord_uid`.

  Raises `Ecto.NoResultsError` if the `User` does not exist.

  ## Examples

      iex> get_user_by_discord_uid!("123456")
      %User{}

      iex> get_user_by_discord_uid("654321")
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by_discord_uid!(String.t()) :: User.t()
  def get_user_by_discord_uid!(discord_uid), do: Repo.get_by!(User, discord_uid: discord_uid)
end
