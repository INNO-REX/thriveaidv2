defmodule Thriveaidv2Web.About.AboutPageLive do
  use Thriveaidv2Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_page: "about")}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
