defmodule DiceMagick.Discord.Create do
  @moduledoc """
  Handles the `!create <NAME>` command.

  Creates a `DiceMagick.Characters.Character` with the specified `name` belonging to the
  `Accounts.User` who sent the message.

  On success, responds with the edit URL for the new `Character`. On failure,
  responds with a human-readable error message.

  ## Examples

  `!create Saidri`
  > ✨ Done! Finish setting up Saidri at https://www.dicemagick.app/...

  `!create Nornys`
  > 💀 You’ve already got a character named Nornys.

  """

  alias DiceMagick.{Characters, Discord}
  alias DiceMagickWeb.{Endpoint, Router, CharacterLive}
  alias Characters.Character

  @behaviour Discord.Command

  @impl true
  def process([name], msg) do
    discord_uid = to_string(msg.author.id)
    user = DiceMagick.Accounts.get_user_by_discord_uid!(discord_uid)

    attrs = %{
      name: name,
      discord_channel_id: to_string(msg.channel_id),
      user_id: user.id
    }

    case Characters.create_character(attrs) do
      {:ok, character} -> {:ok, success_message(character)}
      {:error, changeset} -> {:error, failure_message(changeset, name)}
    end
  end

  @spec success_message(Character.t()) :: String.t()
  defp success_message(%Character{} = character) do
    url = Endpoint.url() <> Router.Helpers.live_path(Endpoint, CharacterLive.Edit, character)
    ":sparkles: Done! Finish setting up #{character.name} at: #{url}"
  end

  @spec failure_message(Ecto.Changeset.t(), String.t()) :: String.t()
  defp failure_message(%Ecto.Changeset{errors: errors}, name) do
    error =
      cond do
        # [todo] Add character name and message re: !retire
        Keyword.has_key?(errors, :discord_channel_id) ->
          "You’ve already got a character in this channel."

        Keyword.has_key?(errors, :name) ->
          "You’ve already got a character named #{name}."

        true ->
          "Something has gone terribly awry."
      end

    ":skull: " <> error
  end
end
