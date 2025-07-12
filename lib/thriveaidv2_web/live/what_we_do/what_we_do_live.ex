defmodule Thriveaidv2Web.WhatWeDo.WhatWeDoLive do
  use Thriveaidv2Web, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:active_tab, "education")
      |> assign(:current_page, "what-we-do")
      # Add this line to track which accordion is open
      |> assign(:open_accordion, nil)

    {:ok, socket}
  end

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    # Reset the open accordion when switching tabs for a cleaner UX
    {:noreply, assign(socket, active_tab: tab, open_accordion: nil)}
  end

  # Add this handler for the accordion
  def handle_event("toggle-accordion", %{"id" => id}, socket) do
    current_open = socket.assigns.open_accordion
    new_open = if current_open == id, do: nil, else: id
    {:noreply, assign(socket, :open_accordion, new_open)}
  end
end
