defmodule Thriveaidv2Web.Home.HomePageLive do
  use Thriveaidv2Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_page: "home")}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
