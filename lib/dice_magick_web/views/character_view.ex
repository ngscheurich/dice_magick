defmodule DiceMagickWeb.CharacterView do
  use DiceMagickWeb, :view

  alias DiceMagickWeb.CharacterLive
  alias Phoenix.HTML.Form

  @spec modifier(Form.t(), atom()) :: integer() | nil
  def modifier(%Form{source: %Ecto.Changeset{changes: changes}}, ability) do
    changes
    |> Map.get(ability, 0)
    |> DiceMagick.Stats.calculate_modifier()
    |> decorate_modifier()
  end

  defp decorate_modifier(mod) when mod >= 0, do: "+#{mod}"
  defp decorate_modifier(mod), do: mod
end
