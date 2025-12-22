defmodule Thriveaidv2Web.Admin.AdminUsersLive do
  use Thriveaidv2Web, :admin_live_view

  alias Phoenix.LiveView.JS

  alias Thriveaidv2.Accounts
  alias Thriveaidv2.Accounts.AdminUser

  @manage_admins "manage_admins"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: "admin", admin_section: :admin_users, page_title: "Admin Users")
     |> assign(admin_user: nil, form: nil)
     |> assign(confirm_delete: nil)
     |> stream(:admin_users, Accounts.list_admin_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"admin_user" => params}, socket) do
    params = maybe_strip_password_param(socket, params)

    changeset =
      socket.assigns.admin_user
      |> Accounts.change_admin_user(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"admin_user" => params}, socket) do
    params = maybe_strip_password_param(socket, params)
    save_admin_user(socket, socket.assigns.live_action, params)
  end

  @impl true
  def handle_event("ask-delete", %{"id" => id}, socket) do
    user = Accounts.get_admin_user!(String.to_integer(id))
    {:noreply, assign(socket, confirm_delete: %{id: user.id, title: user.email})}
  end

  @impl true
  def handle_event("cancel-delete", _params, socket) do
    {:noreply, assign(socket, confirm_delete: nil)}
  end

  @impl true
  def handle_event("confirm-delete", _params, socket) do
    %{id: id} = socket.assigns.confirm_delete
    current = socket.assigns.current_admin_user
    user = Accounts.get_admin_user!(id)

    cond do
      current && current.id == user.id ->
        {:noreply,
         socket
         |> assign(confirm_delete: nil)
         |> put_flash(:error, "You can't delete your own account.")}

      Accounts.has_permission?(user, @manage_admins) &&
          Accounts.count_admins_with_permission(@manage_admins) <= 1 ->
        {:noreply,
         socket
         |> assign(confirm_delete: nil)
         |> put_flash(:error, "You can't delete the last admin who can manage admins.")}

      true ->
        {:ok, _} = Accounts.delete_admin_user(user)

        {:noreply,
         socket
         |> assign(confirm_delete: nil)
         |> put_flash(:info, "Admin deleted.")
         |> stream_delete(:admin_users, user)}
    end
  end

  defp save_admin_user(socket, :new, params) do
    params = Map.put_new(params, "permissions", ["manage_content", "manage_messages"])

    case Accounts.create_admin_user(params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Admin created.")
         |> stream_insert(:admin_users, user, at: 0)
         |> push_patch(to: ~p"/admin/admin-users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_admin_user(socket, :edit, params) do
    current = socket.assigns.current_admin_user
    user = socket.assigns.admin_user
    new_perms = Map.get(params, "permissions", [])

    cond do
      current && user && current.id == user.id && !(@manage_admins in new_perms) ->
        {:noreply,
         socket
         |> put_flash(:error, "You can't remove your own admin-management permission.")
         |> assign_form(Accounts.change_admin_user(user, params))}

      user &&
          Accounts.has_permission?(user, @manage_admins) &&
          !(@manage_admins in new_perms) &&
          Accounts.count_admins_with_permission(@manage_admins) <= 1 ->
        {:noreply,
         socket
         |> put_flash(:error, "You can't remove admin-management from the last admin who has it.")
         |> assign_form(Accounts.change_admin_user(user, params))}

      true ->
        case Accounts.update_admin_user(user, params) do
          {:ok, user} ->
            {:noreply,
             socket
             |> put_flash(:info, "Admin updated.")
             |> stream_insert(:admin_users, user)
             |> push_patch(to: ~p"/admin/admin-users")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign_form(socket, changeset)}
        end
    end
  end

  # Only the superadmin can reset passwords for existing admins.
  # (Password is still required when creating a new admin.)
  defp maybe_strip_password_param(socket, params) when is_map(params) do
    current = socket.assigns[:current_admin_user]

    if socket.assigns.live_action == :edit &&
         current &&
         Map.get(current, :is_superadmin) != true do
      Map.delete(params, "password")
    else
      params
    end
  end

  defp apply_action(socket, :new, _params) do
    user = %AdminUser{}

    socket
    |> assign(page_title: "New Admin")
    |> assign(admin_user: user)
    |> assign_form(Accounts.change_admin_user(user))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = Accounts.get_admin_user!(String.to_integer(id))

    socket
    |> assign(page_title: "Edit Admin")
    |> assign(admin_user: user)
    |> assign_form(Accounts.change_admin_user(user))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(page_title: "Admin Users")
    |> assign(admin_user: nil, form: nil)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

  defp close_modal_js do
    JS.patch(~p"/admin/admin-users")
  end
end


