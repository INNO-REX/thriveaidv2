defmodule Thriveaidv2Web.Admin.DashboardLive do
  use Thriveaidv2Web, :admin_live_view

  import Ecto.Query, warn: false

  alias Thriveaidv2.Repo
  alias Thriveaidv2.Content
  alias Thriveaidv2.Content.NewsPost
  alias Thriveaidv2.Content.SuccessStory
  alias Thriveaidv2.Inbox

  @impl true
  def mount(_params, _session, socket) do
    donations = Content.list_donations()
    
    # Exclude failed donations from total amount
    successful_donations = Enum.reject(donations, &(&1.status == "failed"))
    
    stats = %{
      success_total: Repo.aggregate(SuccessStory, :count, :id),
      success_published: Repo.aggregate(from(s in SuccessStory, where: s.is_published == true), :count, :id),
      news_total: Repo.aggregate(NewsPost, :count, :id),
      news_published: Repo.aggregate(from(n in NewsPost, where: n.is_published == true), :count, :id),
      messages_unread: Inbox.unread_count(),
      donations_total: length(donations),
      donations_amount: Enum.sum(Enum.map(successful_donations, & &1.amount)),
      donations_pending: Enum.count(donations, &(&1.status == "pending")),
      donations_completed: Enum.count(donations, &(&1.status == "completed")),
      donations_failed: Enum.count(donations, &(&1.status == "failed"))
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


