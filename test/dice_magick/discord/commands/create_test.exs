defmodule DiceMagick.Discord.CreateTest do
  use DiceMagick.DataCase

  alias DiceMagick.Discord.Commands
  alias DiceMagick.Repo
  alias DiceMagick.Characters.Character
  alias DiceMagickWeb.{Endpoint, Router, CharacterLive}

  setup do
    user = insert(:user, discord_uid: "1")
    msg = %Nostrum.Struct.Message{author: %{id: 1}, channel_id: 123_456}
    %{msg: msg, user: user}
  end

  test "execute/1 creates character on success", %{msg: msg} do
    assert {:ok, message} = Commands.create(["Dust"], msg)
    character = Repo.get_by!(Character, name: "Dust")

    assert message ==
             ":sparkles: Done! Finish setting up Dust at: " <>
               Endpoint.url() <> Router.Helpers.live_path(Endpoint, CharacterLive.Edit, character)
  end

  test "execute/1 returns error message on failure", %{msg: msg, user: user} do
    insert(:character, name: "Dust", user: user)
    assert {:error, message} = Commands.create(["Dust"], msg)
    assert message == ":skull: You’ve already got a character named Dust."
  end
end
