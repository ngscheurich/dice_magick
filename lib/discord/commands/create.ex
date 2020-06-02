defmodule Discord.Commands.Create do
  @behaviour Discord.Command

  alias Characters.Character

  @doc """
  Handles the `!dm create <NAME>` command.

  Creates a `Characters.Character` with the specified `name` belonging to the
  `Accounts.User` who sent the message.

  On success, responds with the edit URL for the new `Character`. On failure,
  responds with a human-readable error message.

  ## Examples

      !dm create Saidri
      :sparkles: Done! Finish setting up Saidri at https://www.dicemagick.app/...

      !dm create Nornys
      :skull: You’ve already got a character named Nornys.

  """
  @impl true
  def process([name], msg) do
    discord_uid = to_string(msg.author.id)
    user = Accounts.get_user_by_discord_uid!(discord_uid)

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
  def success_message(%Character{} = character) do
    ":sparkles: Done! Finish setting up #{character.name} at: " <>
      Web.Endpoint.url() <>
      Web.Router.Helpers.live_path(Web.Endpoint, Web.CharacterLive.Edit, character)
  end

  @spec failure_message(Ecto.Changeset.t(), String.t()) :: String.t()
  def failure_message(%Ecto.Changeset{errors: errors}, name) do
    error =
      cond do
        Keyword.has_key?(errors, :name) -> "You’ve already got a character named #{name}."
        true -> "Something has gone terribly awry."
      end

    ":skull: " <> error
  end
end
