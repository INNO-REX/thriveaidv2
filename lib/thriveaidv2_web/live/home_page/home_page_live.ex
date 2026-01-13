defmodule Thriveaidv2Web.Home.HomePageLive do
  use Thriveaidv2Web, :live_view

  alias Thriveaidv2.Content

  @impl true
  def mount(_params, _session, socket) do
    partners = Content.list_active_partners()
    {:ok, assign(socket, current_page: "home", partners: partners)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
