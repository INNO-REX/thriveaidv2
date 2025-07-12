defmodule Thriveaidv2Web.Projects.ProjectsLive do
  use Thriveaidv2Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_page: "projects")}
  end
end
