defmodule DiceMagickWeb.LayoutView do
  @moduledoc false

  use DiceMagickWeb, :view

  @doc """
  Returns OAuth2 URL for the configured Discord app.
  """
  @spec discord_oauth_url() :: String.t()
  def discord_oauth_url do
    client_id =
      :ueberauth
      |> Application.get_env(Ueberauth.Strategy.Discord.OAuth)
      |> Keyword.get(:client_id)

    redirect_uri = DiceMagickWeb.Endpoint.url() <> "/auth/discord/callback"

    query =
      URI.encode_query(%{
        client_id: client_id,
        prompt: nil,
        redirect_uri: redirect_uri,
        response_type: "code",
        scope: "identify guilds"
      })

    "https://discordapp.com/api/oauth2/authorize?#{query}"
  end
end
