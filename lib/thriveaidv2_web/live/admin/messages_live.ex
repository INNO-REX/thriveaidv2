defmodule Thriveaidv2Web.Admin.MessagesLive do
  use Thriveaidv2Web, :admin_live_view

  alias Thriveaidv2.Inbox
  alias Thriveaidv2.Inbox.ContactMessage

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: "admin", admin_section: :messages, page_title: "Messages")
     |> assign(selected_message: nil)
     |> assign(confirm_delete: nil)
     |> assign(reply_form: nil)
     |> stream(:messages, Inbox.list_contact_messages())}
  end

  @impl true
  def handle_event("open", %{"id" => id}, socket) do
    msg = Inbox.get_contact_message!(id)
    reply_defaults = %{
      "reply_subject" => if(msg.subject, do: "Re: #{msg.subject}", else: "Re:"),
      "reply_body" => ""
    }

    {:noreply,
     socket
     |> assign(selected_message: msg)
     |> assign(reply_form: to_form(Inbox.reply_changeset(msg, reply_defaults)))}
  end

  @impl true
  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, selected_message: nil, reply_form: nil)}
  end

  @impl true
  def handle_event("toggle-read", %{"id" => id}, socket) do
    msg = Inbox.get_contact_message!(id)

    case Inbox.update_contact_message(msg, %{is_read: !msg.is_read}) do
      {:ok, msg} ->
        {:noreply,
         socket
         |> stream_insert(:messages, msg)
         |> assign(unread_messages_count: Inbox.unread_count())
         |> assign(selected_message: if(socket.assigns.selected_message && socket.assigns.selected_message.id == msg.id, do: msg, else: socket.assigns.selected_message))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update message.")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    msg = Inbox.get_contact_message!(id)
    {:ok, _} = Inbox.delete_contact_message(msg)

    {:noreply,
     socket
     |> stream_delete(:messages, msg)
     |> assign(selected_message: if(socket.assigns.selected_message && socket.assigns.selected_message.id == msg.id, do: nil, else: socket.assigns.selected_message))}
  end

  @impl true
  def handle_event("ask-delete", %{"id" => id}, socket) do
    msg = Inbox.get_contact_message!(id)
    {:noreply, assign(socket, confirm_delete: %{id: msg.id, title: msg.subject})}
  end

  @impl true
  def handle_event("confirm-delete", _params, socket) do
    %{id: id} = socket.assigns.confirm_delete
    msg = Inbox.get_contact_message!(id)
    {:ok, _} = Inbox.delete_contact_message(msg)

    {:noreply,
     socket
     |> assign(confirm_delete: nil)
     |> stream_delete(:messages, msg)
     |> assign(unread_messages_count: Inbox.unread_count())
     |> assign(selected_message: if(socket.assigns.selected_message && socket.assigns.selected_message.id == msg.id, do: nil, else: socket.assigns.selected_message))}
  end

  @impl true
  def handle_event("cancel-delete", _params, socket) do
    {:noreply, assign(socket, confirm_delete: nil)}
  end

  @impl true
  def handle_event("validate-reply", %{"contact_message" => params}, socket) do
    msg = socket.assigns.selected_message

    changeset =
      msg
      |> Inbox.reply_changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, reply_form: to_form(changeset))}
  end

  @impl true
  def handle_event("send-reply", %{"contact_message" => params}, socket) do
    msg = socket.assigns.selected_message
    admin = socket.assigns[:current_admin_user]

    case Inbox.reply_to_message(msg, params, admin) do
      {:ok, msg} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reply sent.")
         |> stream_insert(:messages, msg)
         |> assign(selected_message: msg)
         |> assign(unread_messages_count: Inbox.unread_count())
         |> assign(reply_form: to_form(Inbox.reply_changeset(msg, %{"reply_subject" => msg.reply_subject || "", "reply_body" => msg.reply_body || ""})))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, reply_form: to_form(changeset))}
    end
  end

  defp initials(%ContactMessage{} = msg) do
    msg.name
    |> to_string()
    |> String.trim()
    |> String.split(~r/\s+/u, trim: true)
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
    |> case do
      "" -> "?"
      s -> s
    end
  end
end


