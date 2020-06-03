defmodule DiceMagick.Discord.CreateTest do
  use DiceMagick.DataCase
  alias DiceMagick.{Discord, Characters}

  setup do
    user = insert(:user, discord_uid: "1")
    msg = %Nostrum.Struct.Message{author: %{id: 1}, channel_id: 123_456}
    %{msg: msg, user: user}
  end

  test "process/1 creates character on success", %{msg: msg} do
    assert {:ok, message} = Discord.Create.process(["Dust"], msg)
    character = DiceMagick.Repo.get_by!(Characters.Character, name: "Dust")

    assert message ==
             ":sparkles: Done! Finish setting up Dust at: " <>
               DiceMagickWeb.Endpoint.url() <>
               DiceMagickWeb.Router.Helpers.live_path(
                 DiceMagickWeb.Endpoint,
                 DiceMagickWeb.CharacterLive.Edit,
                 character
               )
  end

  test "process/1 returns error message on failure", %{msg: msg, user: user} do
    insert(:character, name: "Dust", user: user)
    assert {:error, message} = Discord.Create.process(["Dust"], msg)
    assert message == ":skull: You’ve already got a character named Dust."
  end
end
