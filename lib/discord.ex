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
    id = to_string(msg.author.id)
    result = ExDiceRoller.roll(input)

    character =
      User
      # [todo] Move all this Repo code to Accounts context.
      |> where(discord_uid: ^id)
      |> limit(1)
      |> Repo.one!()
      |> Repo.preload(:characters)
      |> Map.get(:characters)
      |> List.first()

    # [todo] Extract this logic into a function.
    message = """
    **#{character.name}** rolls `#{input}`…
    :game-die: Result: **#{result}**
    """

    Api.create_message(msg.channel_id, message)
  end

  def handle_event({:MESSAGE_CREATE, %{content: "!dm " <> input} = msg, _ws_state}) do
    id = to_string(msg.author.id)

    character =
      User
      |> where(discord_uid: ^id)
      |> limit(1)
      |> Repo.one!()
      |> Repo.preload(:characters)
      |> Map.get(:characters)
      |> List.first()

    rolls =
      character.id
      |> Characters.Worker.state()
      |> Map.get(:rolls)
      |> Enum.filter(fn roll ->
        name = String.downcase(roll.name)
        input = String.downcase(input)
        String.starts_with?(name, input)
      end)

    message =
      case rolls do
        [roll] ->
          result = ExDiceRoller.roll(roll.expression)

          """
          **#{character.name}** rolls _#{roll.name}_ (`#{roll.expression}`)…
          :game-die: Result: **#{result}**
          """

        _ ->
          "Sorry, I couldn’t find a roll matching “#{msg.content}”."
      end

    Api.create_message(msg.channel_id, message)
  end

  def handle_event(_event), do: :noop
end
