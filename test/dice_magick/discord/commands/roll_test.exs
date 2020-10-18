defmodule DiceMagick.Discord.Commands.RollTest do
  use DiceMagick.DataCase

  import DiceMagick.Discord.Commands.Roll, only: [execute: 2]

  alias DiceMagick.Rolls.Roll
  alias DiceMagick.Characters

  setup do
    user = insert(:user, discord_uid: "1")
    msg = %Nostrum.Struct.Message{author: %{id: 1}, channel_id: "123456"}

    %{msg: msg, user: user}
  end

  test "execute/1 returns named roll outcome", %{msg: msg, user: user} do
    insert(:character, discord_channel_id: "123456")
    character = insert(:character, name: "Dust", discord_channel_id: "123456", user: user)

    roll = %Roll{name: "Stealth Check", expression: "1d20 + 2", character_id: character.id}
    opts = [character_id: character.id, state: %{rolls: [roll]}]

    start_supervised!({Characters.Worker, opts})
    assert {:ok, message} = execute(["ste"], msg)

    regex = ~r/^\*\*Dust\*\* rolls _Stealth Check_ \(`1d20 \+ 2`\)…\n:game_die: Result:/

    assert Regex.match?(regex, message)
  end

  test "execute/1 returns ad-hoc roll outcome", %{msg: msg, user: user} do
    insert(:character, discord_channel_id: "123456")
    insert(:character, name: "Dust", discord_channel_id: "123456", user: user)

    assert {:ok, message} = execute(["3d4"], msg)

    regex = ~r/^\*\*Dust\*\* rolls `3d4`…\n:game_die: Result:/

    assert Regex.match?(regex, message)
  end

  test "execute/1 returns error message with invalid roll expression", %{msg: msg, user: user} do
    insert(:character, name: "Dust", discord_channel_id: "123456", user: user)
    assert {:error, message} = execute(["x"], msg)

    assert message ==
             ":skull: No matching rolls were found, and `x` is not a valid dice expression."
  end

  test "execute/1 returns error message when no character exists", %{msg: msg} do
    assert {:error, message} = execute(["1d3"], msg)

    assert message = """
           :crystal_ball: You don’t have any characters in this channel.
           You can `!create` one here, or `!transfer` one from another channel.
           """
  end
end
