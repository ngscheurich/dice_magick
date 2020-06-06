defmodule DiceMagick.Discord.RollTest do
  use DiceMagick.DataCase
  alias DiceMagick.{Discord, Rolls}

  setup do
    user = insert(:user, discord_uid: "1")
    msg = %Nostrum.Struct.Message{author: %{id: 1}, channel_id: "123456"}

    %{msg: msg, user: user}
  end

  test "process/1 returns named roll outcome", %{msg: msg, user: user} do
    character = insert(:character, name: "Dust", discord_channel_id: "123456", user: user)
    roll = %Rolls.Roll{name: "Stealth Check", expression: "1d20 + 2", character_id: character.id}
    opts = [character_id: character.id, state: %{rolls: [roll]}]
    start_supervised!({DiceMagick.Characters.Worker, opts})
    assert {:ok, message} = Discord.Roll.process(["ste"], msg)

    regex = ~r/^\*\*Dust\*\* rolls _Stealth Check_ \(`1d20 \+ 2`\)…\n:game_die: Result:/

    assert Regex.match?(regex, message)
  end

  test "process/1 returns ad-hoc roll outcome", %{msg: msg, user: user} do
    insert(:character, name: "Dust", discord_channel_id: "123456", user: user)
    assert {:ok, message} = Discord.Roll.process(["3d4"], msg)
    regex = ~r/^\*\*Dust\*\* rolls `3d4`…\n:game_die: Result:/
    assert Regex.match?(regex, message)
  end

  test "process/1 returns error message with invalid roll expression", %{msg: msg, user: user} do
    insert(:character, name: "Dust", discord_channel_id: "123456", user: user)
    assert {:error, message} = Discord.Roll.process(["x"], msg)

    assert message ==
             ":skull: No matching rolls were found, and `x` is not a valid dice expression."
  end

  test "process/1 returns error message when no character exists", %{msg: msg} do
    assert {:error, message} = Discord.Roll.process(["1d3"], msg)

    assert message = """
           :crystal_ball: You don’t have any characters in this channel.
           You can `!create` one here, or `!transfer` one from another channel.
           """
  end
end
