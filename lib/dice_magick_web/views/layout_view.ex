defmodule DiceMagickWeb.LayoutView do
  use DiceMagickWeb, :view

  @doc """
  Generate Discord OAuth2 URL.
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
        scope: "identify"
      })

    "https://discordapp.com/api/oauth2/authorize?#{query}"
  end
end
