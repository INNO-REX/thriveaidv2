defmodule Thriveaidv2Web.Contact.ContactLive do
  use Thriveaidv2Web, :live_view

  alias Thriveaidv2.Content
  alias Thriveaidv2.Inbox
  alias Thriveaidv2.Inbox.ContactMessage

  @impl true
  def mount(_params, _session, socket) do
    changeset = Inbox.change_contact_message(%ContactMessage{})
    partners = Content.list_active_partners()

    {:ok,
     socket
     |> assign(current_page: "contact")
     |> assign(partners: partners)
     |> assign(form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"contact_message" => params}, socket) do
    changeset =
      %ContactMessage{}
      |> Inbox.change_contact_message(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("send", %{"contact_message" => params}, socket) do
    case Inbox.create_contact_message(params) do
      {:ok, _msg} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thanks! Your message has been sent.")
         |> assign(form: to_form(Inbox.change_contact_message(%ContactMessage{})))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
