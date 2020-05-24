defmodule Discord do
  @moduledoc """
  [todo] Write documentation
  """

  use Nostrum.Consumer
  import Ecto.Query
  alias Accounts.User
  alias Nostrum.Api
  alias Repo

  def start_link, do: Consumer.start_link(__MODULE__)

  def handle_event({:MESSAGE_CREATE, %{content: "!dm roll " <> input} = msg, _ws_state}) do
    result = ExDiceRoller.roll(input)

    # [todo] Extract this logic into a function.
    message = """
    Rolling `#{input}`…
    :game-die: Result: **#{result}**
    """

    Api.create_message(msg.channel_id, message)
  end

  def handle_event({:MESSAGE_CREATE, %{content: "!dm " <> input} = msg, _ws_state}) do
    id = to_string(msg.author.id)

    user =
      User
      |> where(discord_uid: ^id)
      |> limit(1)
      |> Repo.one!()
      |> Repo.preload(characters: :rolls)

    character = List.first(user.characters)

    rolls =
      character.rolls
      |> Enum.filter(fn roll ->
        name = String.downcase(roll.name)
        input = String.downcase(input)
        String.starts_with?(name, input)
      end)

    message =
      case Enum.count(rolls) do
        0 ->
          "Sorry, I couldn’t find a roll matching “#{msg.content}”."

        _ ->
          roll = List.first(rolls)
          result = ExDiceRoller.roll(roll.expression)

          """
          Rolling _#{roll.name}_ (`#{roll.expression}`)…
          :game-die: Result: **#{result}**
          """
      end

    Api.create_message(msg.channel_id, message)
  end

  def handle_event(_event), do: :noop
end
