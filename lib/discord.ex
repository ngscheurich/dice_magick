defmodule Discord do
  @moduledoc """
  [todo] Write documentation
  """

  use Nostrum.Consumer

  import Ecto.Query

  alias Accounts.User
  alias Nostrum.Api
  alias Repo
  alias Web.Router.Helpers, as: Routes
  alias Discord.Commands

  def start_link, do: Consumer.start_link(__MODULE__)

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: "!dm create " <> name} = msg, _ws}) do
    {_, message} = Commands.Create.process([name], msg)
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
          "Sorry, I couldn’t find a roll matching “#{input}”."
      end

    Api.create_message(msg.channel_id, message)
  end

  def handle_event(_event), do: :noop
end
