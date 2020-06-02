defmodule Discord do
  @moduledoc """
  [todo] Write documentation.
  """

  use Nostrum.Consumer

  alias Nostrum.Api
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

  @type opts() :: [{:roll_name, String.t()}]
  @spec roll_message(String.t(), String.t(), Integer.t(), opts()) :: String.t()
  @doc """
  [todo] Write documentation.
  """
  def roll_message(character_name, expression, outcome, opts \\ []) do
    info =
      case Keyword.get(opts, :roll_name) do
        nil -> "**#{character_name}** rolls `#{expression}`…"
        roll_name -> "**#{character_name}** rolls _#{roll_name}_ (`#{expression}`)…"
      end

    """
    #{info}
    :game-die: Result: **#{outcome}**
    """
  end

  @doc """
  [todo] Write documentation.
  """
  @spec send_message(Integer.t(), String.t()) :: {:ok, Nostrum.Struct.Message.t} | any()
  def send_message(channel_id, message), do: Api.create_message(channel_id, message)
end
