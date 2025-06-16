defmodule Thriveaidv2Web.AboutPageLive do
  use Thriveaidv2Web, :live_view
  import Thriveaidv2Web.CoreComponents
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
