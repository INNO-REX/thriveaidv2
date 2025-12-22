defmodule Thriveaidv2Web.Admin.DashboardLive do
  use Thriveaidv2Web, :admin_live_view

  import Ecto.Query, warn: false

  alias Thriveaidv2.Repo
  alias Thriveaidv2.Content.NewsPost
  alias Thriveaidv2.Content.SuccessStory
  alias Thriveaidv2.Inbox

  @impl true
  def mount(_params, _session, socket) do
    stats = %{
      success_total: Repo.aggregate(SuccessStory, :count, :id),
      success_published: Repo.aggregate(from(s in SuccessStory, where: s.is_published == true), :count, :id),
      news_total: Repo.aggregate(NewsPost, :count, :id),
      news_published: Repo.aggregate(from(n in NewsPost, where: n.is_published == true), :count, :id),
      messages_unread: Inbox.unread_count()
    }

    {:ok,
     assign(socket,
       current_page: "admin",
       admin_section: :dashboard,
       page_title: "Dashboard",
       stats: stats
     )}
  end
end


