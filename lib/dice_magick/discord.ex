defmodule DiceMagick.Discord do
  @moduledoc """
  Provides functions for interfacing with the Discord API. These functions
  """

  alias DiceMagick.Characters.Character
  alias DiceMagick.Rolls
  alias Nostrum.Api, as: DiscordAPI

  @doc """
  Sends a message to a Discord text channel.

  ## Examples

      iex> send_message(12345678980, "Hello, everyone.")
      {:ok, %Nostrum.Struct.Message{}}

      iex> send_message(0987654321, "Hello, everyone?")
      :error

  """
  @spec send_message(Integer.t(), String.t()) :: {:ok, Nostrum.Struct.Message.t()} | :error
  def send_message(channel_id, message) do
    {channel_id, _} = Integer.parse(channel_id)
    DiscordAPI.create_message(channel_id, message)
  end

  @doc """
  Sends a direct message to a Discord user.

  ## Examples

      iex> send_dm!(1234567890, "This is for your eyes only…")
      %Nostrum.Struct.Message{}

  """
  @spec send_dm!(Integer.t(), String.t()) :: Nostrum.Struct.Message.t()
  def send_dm!(user_id, message) do
    %{id: channel_id} = DiscordAPI.create_dm!(user_id)
    DiscordAPI.create_message!(channel_id, message)
  end

  @doc """
  Returns a formatted roll result message.

  ## Examples

      iex> roll_message

  """
  @spec roll_message(Character.t(), Rolls.Result.t(), variant: String.t()) :: :String.t()
  def roll_message(%Character{} = character, %Rolls.Result{} = result, opts \\ []) do
    info = roll_info(result)
    variant = roll_variant(opts)
    faces = roll_faces(result)

    """
    **#{character.name}** rolls #{info}#{variant}…
    :game_die: Result: **#{result.total}**#{faces}
    """
  end

  @spec roll_info(Rolls.Result.t()) :: String.t()
  defp roll_info(%{name: name, expression: expression}) when not is_nil(name) do
    "_#{name}_ (`#{expression}`)"
  end

  defp roll_info(%{expression: expression}), do: "`#{expression}`"

  @spec roll_variant(keyword()) :: String.t()
  defp roll_variant(opts) do
    case opts[:variant] do
      :advantage -> " with **advantage**"
      :disadvantage -> " with **disadvantage**"
      _ -> ""
    end
  end

  @spec roll_faces(Rolls.Result.t()) :: String.t()
  defp roll_faces(%{faces: faces}) when not is_nil(faces) do
    " (`#{Enum.join(faces, ", ")}`)"
  end

  defp roll_faces(_result), do: ""
end
