defmodule Thriveaidv2Web.News.NewsLive do
  use Thriveaidv2Web, :live_view

  alias Thriveaidv2.Content

  @impl true
  def mount(_params, _session, socket) do
    news_posts = Content.list_published_news_posts()
    partners = Content.list_active_partners()

    {:ok,
     assign(socket,
       news_posts: news_posts,
       selected_post: nil,
       current_page: "news",
       partners: partners
     )}
  end

  @impl true
  def handle_event("show-article", %{"id" => id}, socket) do
    id = String.to_integer(id)
    post = Enum.find(socket.assigns.news_posts, &(&1.id == id))
    {:noreply, assign(socket, selected_post: post)}
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, selected_post: nil)}
  end

  def date_label_for(post) do
    cond do
      is_binary(post.date_label) and String.trim(post.date_label) != "" ->
        post.date_label

      not is_nil(post.published_at) ->
        Calendar.strftime(post.published_at, "%b %Y")

      true ->
        "—"
    end
  end
end
