defmodule Rolls do
  @moduledoc """
  [todo] Write documentation
  """

  alias Rolls.Roll
  alias Repo

  @doc """
  Creates a `Roll`.

  ## Examples

      iex> create_roll(%{field: value})
      {:ok, %Roll{}}

      iex> create_roll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_roll(map) :: {:ok, Roll.t()} | {:error, Changeset.t()}
  def create_roll(attrs \\ %{}) do
    %Roll{}
    |> Roll.changeset(attrs)
    |> Repo.insert()
  end
end
