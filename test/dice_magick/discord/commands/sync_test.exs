defmodule DiceMagick.Discord.SyncTest do
  use DiceMagick.DataCase
  alias DiceMagick.Discord

  setup do
    user = insert(:user, discord_uid: "1")
    character = insert(:character, discord_channel_id: "123456", user: user)
    msg = %Nostrum.Struct.Message{author: %{id: 1}, channel_id: 123_456}
    %{msg: msg, character: character}
  end

  test "process/1 synchronizes rolls", %{msg: msg} do
    assert {:ok, message} = Discord.Sync.process([], msg)
  end
end
