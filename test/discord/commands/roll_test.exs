defmodule Discord.Commands.RollTest do
  use DataCase

  setup do
    user = insert(:user, discord_uid: "1")
    character = insert(:character, name: "Dust", discord_channel_id: "123456", user: user)
    msg = %Nostrum.Struct.Message{author: %{id: 1}, channel_id: "123456"}

    %{msg: msg, character: character}
  end

  test "process/1 returns named roll outcome", %{msg: msg, character: character} do
    roll = %Rolls.Roll{name: "Stealth Check", expression: "1d20 + 2", character_id: character.id}
    opts = [character_id: character.id, state: %{rolls: [roll]}]
    start_supervised!({Characters.Worker, opts})
    assert {:ok, message} = Discord.Commands.Roll.process(["ste"], msg)

    regex =
      ~r/^\*\*Dust\*\* rolls _Stealth Check_ \(`1d20 \+ 2`\)…\n:game-die: Result: \*\*\d+\*\*$/

    assert Regex.match?(regex, message)
  end

  test "process/1 returns ad-hoc roll outcome", %{msg: msg} do
    assert {:ok, message} = Discord.Commands.Roll.process(["3d4"], msg)
    regex = ~r/^\*\*Dust\*\* rolls `3d4`…\n:game-die: Result: \*\*\d+\*\*$/
    assert Regex.match?(regex, message)
  end

  test "process/1 returns error message with invalid roll expression", %{msg: msg} do
    assert {:error, message} = Discord.Commands.Roll.process(["x"], msg)
    assert message == ":skull: x is not a valid roll expression."
  end
end
