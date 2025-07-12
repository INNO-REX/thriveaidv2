defmodule Thriveaidv2Web.Contact.ContactLive do
  use Thriveaidv2Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_page: "contact")}
  end
end
