defmodule AuthHelpers do
  alias Accounts.User
  alias Plug.Conn

  @spec authenticate(Conn.t(), User.t()) :: Conn.t()
  def authenticate(%Conn{} = conn, %User{} = user), do: Conn.assign(conn, :current_user, user)

  @spec authenticate(Conn.t()) :: Conn.t()
  def authenticate(%Conn{} = conn) do
    user = Factory.insert(:user)
    authenticate(conn, user)
  end
end
