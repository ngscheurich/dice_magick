defmodule DiceWizard.Schema do
  @moduledoc """
  Defines a macro that is useful for creating Ecto schemas.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end
