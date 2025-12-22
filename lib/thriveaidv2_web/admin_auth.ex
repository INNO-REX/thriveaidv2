defmodule Thriveaidv2Web.AdminAuth do
  @moduledoc false

  import Phoenix.LiveView

  alias Thriveaidv2.Accounts
  alias Thriveaidv2.Inbox

  def on_mount(:mount_current_admin, _params, session, socket) do
    admin_user = get_admin_from_session(session)

    socket =
      socket
      |> Phoenix.Component.assign(:current_admin_user, admin_user)
      |> Phoenix.Component.assign(:admin_permissions, permissions_for(admin_user))
      |> Phoenix.Component.assign(:can_manage_admins, can?(admin_user, "manage_admins"))
      |> Phoenix.Component.assign(:can_manage_content, can?(admin_user, "manage_content"))
      |> Phoenix.Component.assign(:can_manage_messages, can?(admin_user, "manage_messages"))
      |> Phoenix.Component.assign(:unread_messages_count, unread_messages_count(admin_user))

    {:cont, socket}
  end

  def on_mount(:require_admin, params, session, socket) do
    admin_user = get_admin_from_session(session)

    if admin_user do
      socket =
        socket
        |> Phoenix.Component.assign(:current_admin_user, admin_user)
        |> Phoenix.Component.assign(:admin_permissions, permissions_for(admin_user))
        |> Phoenix.Component.assign(:can_manage_admins, can?(admin_user, "manage_admins"))
        |> Phoenix.Component.assign(:can_manage_content, can?(admin_user, "manage_content"))
        |> Phoenix.Component.assign(:can_manage_messages, can?(admin_user, "manage_messages"))
        |> Phoenix.Component.assign(:unread_messages_count, unread_messages_count(admin_user))

      {:cont, socket}
    else
      return_to =
        case socket.private[:live_view_route] do
          %{path: path} when is_binary(path) -> path
          _ -> Map.get(params, "return_to")
        end

      to =
        if is_binary(return_to) and String.trim(return_to) != "" do
          "/admin/login?return_to=#{URI.encode_www_form(return_to)}"
        else
          "/admin/login"
        end

      {:halt, redirect(socket, to: to)}
    end
  end

  def on_mount({:require_permission, permission}, _params, session, socket)
      when is_binary(permission) do
    admin_user = get_admin_from_session(session)

    if admin_user && Accounts.has_permission?(admin_user, permission) do
      socket =
        socket
        |> Phoenix.Component.assign(:current_admin_user, admin_user)
        |> Phoenix.Component.assign(:admin_permissions, permissions_for(admin_user))
        |> Phoenix.Component.assign(:can_manage_admins, can?(admin_user, "manage_admins"))
        |> Phoenix.Component.assign(:can_manage_content, can?(admin_user, "manage_content"))
        |> Phoenix.Component.assign(:can_manage_messages, can?(admin_user, "manage_messages"))
        |> Phoenix.Component.assign(:unread_messages_count, unread_messages_count(admin_user))

      {:cont, socket}
    else
      socket =
        socket
        |> put_flash(:error, "You are not authorized to view that page.")
        |> redirect(to: "/admin")

      {:halt, socket}
    end
  end

  defp unread_messages_count(nil), do: 0
  defp unread_messages_count(_admin_user), do: Inbox.unread_count()

  defp permissions_for(nil), do: []
  defp permissions_for(admin_user), do: Map.get(admin_user, :permissions, []) || []

  defp can?(nil, _perm), do: false
  defp can?(admin_user, perm), do: Accounts.has_permission?(admin_user, perm)

  defp get_admin_from_session(session) when is_map(session) do
    case Map.get(session, "admin_user_id") || Map.get(session, :admin_user_id) do
      nil ->
        nil

      id when is_integer(id) ->
        Accounts.get_admin_user(id)

      id when is_binary(id) ->
        case Integer.parse(id) do
          {int, ""} -> Accounts.get_admin_user(int)
          _ -> nil
        end

      _ ->
        nil
    end
  end
end


