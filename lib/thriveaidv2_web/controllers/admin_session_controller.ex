defmodule Thriveaidv2Web.AdminSessionController do
  use Thriveaidv2Web, :controller

  alias Thriveaidv2.Accounts

  def new(conn, params) do
    if conn.assigns[:current_admin_user] do
      redirect(conn, to: ~p"/admin")
    else
      render(conn, :new,
        page_title: "Admin Login",
        return_to: Map.get(params, "return_to"),
        email: ""
      )
    end
  end

  def create(conn, %{"admin" => %{"email" => email, "password" => password} = _admin_params} = params) do
    return_to =
      (get_in(params, ["admin", "return_to"]) || Map.get(params, "return_to"))
      |> normalize_return_to()

    case Accounts.authenticate_admin(String.trim(email), password) do
      {:ok, user} ->
        conn
        |> configure_session(renew: true)
        |> put_session(:admin_user_id, user.id)
        |> put_flash(:info, "Welcome back.")
        |> redirect(to: return_to || ~p"/admin")

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid email or password.")
        |> render(:new, page_title: "Admin Login", return_to: return_to, email: email)
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: ~p"/")
  end

  defp normalize_return_to(return_to) when is_binary(return_to) do
    rt = String.trim(return_to)

    cond do
      rt == "" -> nil
      String.starts_with?(rt, "/") -> rt
      true -> nil
    end
  end

  defp normalize_return_to(_), do: nil
end


