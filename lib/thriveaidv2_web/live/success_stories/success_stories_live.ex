defmodule Thriveaidv2Web.SuccessStories.SuccessStoriesLive do
  use Thriveaidv2Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, selected_story: nil, current_page: "success-stories")}
  end

  @impl true
  def handle_event("open-story", %{"story" => story}, socket) do
    {:noreply, assign(socket, selected_story: story)}
  end

  @impl true
  def handle_event("close-story", _params, socket) do
    {:noreply, assign(socket, selected_story: nil)}
  end

  @impl true
  def handle_event("toggle-story", %{"id" => id}, socket) do
    {:noreply, assign(socket, expanded_story: id)}
  end
end
