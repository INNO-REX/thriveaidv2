defmodule Thriveaidv2Web.SuccessStories.SuccessStoriesLive do
  use Thriveaidv2Web, :live_view

  alias Thriveaidv2.Content

  @impl true
  def mount(_params, _session, socket) do
    stories = Content.list_published_success_stories()

    {:ok,
     assign(socket,
       success_stories: stories,
       selected_story: nil,
       current_page: "success-stories"
     )}
  end

  @impl true
  def handle_event("open-story", %{"id" => id}, socket) do
    id = String.to_integer(id)
    story = Enum.find(socket.assigns.success_stories, &(&1.id == id))
    {:noreply, assign(socket, selected_story: story)}
  end

  @impl true
  def handle_event("close-story", _params, socket) do
    {:noreply, assign(socket, selected_story: nil)}
  end

end
