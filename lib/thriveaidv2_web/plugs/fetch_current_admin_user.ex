defmodule Thriveaidv2Web.Plugs.FetchCurrentAdminUser do
  @moduledoc false

  import Plug.Conn

  alias Thriveaidv2.Accounts

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    admin_user =
      case get_session(conn, :admin_user_id) do
        nil -> nil
        id when is_integer(id) -> Accounts.get_admin_user(id)
        id when is_binary(id) -> parse_and_get(id)
        _ -> nil
      end

    assign(conn, :current_admin_user, admin_user)
  end

  defp parse_and_get(id) do
    case Integer.parse(id) do
      {int, ""} -> Accounts.get_admin_user(int)
      _ -> nil
    end
  end
end


