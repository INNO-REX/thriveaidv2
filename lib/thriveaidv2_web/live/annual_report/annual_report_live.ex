defmodule Thriveaidv2Web.AnnualReport.AnnualReportLive do
  use Thriveaidv2Web, :live_view

  alias Thriveaidv2.Content

  @impl true
  def mount(_params, _session, socket) do
    partners = Content.list_active_partners()

    {:ok,
     assign(socket,
       current_page: "annual-report",
       partners: partners,
       report: nil,
       page_title: "Annual Report"
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    # Only show the latest published annual report
    report = Content.get_latest_published_annual_report()

    socket
    |> assign(report: report)
    |> assign(page_title: if(report, do: "Annual Report #{report.year}", else: "Annual Report"))
  end

  defp apply_action(socket, _action, _params) do
    socket
  end

  # Helper function for templates
  def format_number(num) when is_integer(num) and num > 0 do
    num
    |> Integer.to_string()
    |> String.replace(~r/(\d)(?=(\d{3})+(?!\d))/, "\\1,")
    |> Kernel.<>("+")
  end

  def format_number(_), do: "0+"
end


