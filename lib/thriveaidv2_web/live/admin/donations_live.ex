defmodule Thriveaidv2Web.Admin.DonationsLive do
  use Thriveaidv2Web, :admin_live_view

  alias Phoenix.LiveView.JS
  alias Thriveaidv2.Content

  @per_page 20

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: "admin")
     |> assign(admin_section: :donations)
     |> assign(page_title: "Donations")
     |> assign(selected_donation: nil)
     |> assign(form: nil)
     |> assign(confirm_status_change: nil)
     |> assign(filters: %{
       status: "all",
       payment_method: "all",
       search: "",
       date_from: nil,
       date_to: nil
     })
     |> assign(page: 1)
     |> assign(pagination: nil)
     |> assign(donations: [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    page = parse_page(params)
    filters = parse_filters(params, socket.assigns.filters || %{})

    pagination_opts = [
      page: page,
      per_page: @per_page,
      status: filters.status,
      payment_method: filters.payment_method,
      search: filters.search,
      date_from: filters.date_from,
      date_to: filters.date_to
    ]

    pagination = Content.list_donations_paginated(pagination_opts)

    socket
    |> assign(:page_title, "Donations")
    |> assign(:page, page)
    |> assign(:filters, filters)
    |> assign(:pagination, pagination)
    |> assign(:donations, pagination.entries)
    |> assign(:build_patch_path, &build_patch_path/2)
    |> assign(:page_range_helper, &page_range_helper/2)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    donation = Content.get_donation!(id)
    socket
    |> assign(:page_title, "Donation Details")
    |> assign(:selected_donation, donation)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    donation = Content.get_donation!(id)
    socket
    |> assign(:page_title, "Edit Donation")
    |> assign(:selected_donation, donation)
    |> assign_form(Content.change_donation(donation))
  end

  defp apply_action(socket, :print, %{"id" => id}) do
    donation = Content.get_donation!(id)
    socket
    |> assign(:page_title, "Print Donation")
    |> assign(:selected_donation, donation)
  end

  @impl true
  def handle_event("ask-status-change", %{"_id" => id, "status" => new_status}, socket) do
    donation = Content.get_donation!(id)
    
    # Only show confirmation if status is actually changing
    if donation.status == new_status do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> assign(confirm_status_change: %{
         id: id,
         current_status: donation.status,
         new_status: new_status,
         donor_name: donation.donor_name,
         amount: donation.amount
       })}
    end
  end

  def handle_event("cancel-status-change", _params, socket) do
    {:noreply, assign(socket, confirm_status_change: nil)}
  end

  def handle_event("confirm-status-change", _params, socket) do
    %{id: id, new_status: status} = socket.assigns.confirm_status_change
    donation = Content.get_donation!(id)
    
    case Content.update_donation(donation, %{"status" => status}) do
      {:ok, _donation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Donation status updated successfully")
         |> reload_donations()
         |> assign(confirm_status_change: nil)
         |> assign(pending_donations_count: Content.count_pending_donations())}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to update donation status")
         |> assign(confirm_status_change: nil)}
    end
  end

  def handle_event("apply-filters", params, socket) do
    filters = parse_filters(params, socket.assigns.filters)
    path = build_patch_path(1, filters)
    
    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:page, 1)
     |> push_patch(to: path)}
  end

  def handle_event("clear-filters", _params, socket) do
    filters = %{
      status: "all",
      payment_method: "all",
      search: "",
      date_from: nil,
      date_to: nil
    }
    path = build_patch_path(1, filters)
    
    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:page, 1)
     |> push_patch(to: path)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    donation = Content.get_donation!(id)
    {:ok, _} = Content.delete_donation(donation)

    {:noreply,
     socket
     |> put_flash(:info, "Donation deleted successfully")
     |> reload_donations()
     |> assign(pending_donations_count: Content.count_pending_donations())}
  end

  def handle_event("print-donation", %{"id" => id}, socket) do
    donation = Content.get_donation!(id)
    {:noreply,
     socket
     |> push_navigate(to: ~p"/admin/donations/#{donation.id}/print")}
  end

  def handle_event("validate", %{"donation" => params}, socket) do
    donation = socket.assigns.selected_donation
    
    # Always preserve the original amount - it cannot be changed
    params = Map.put(params, "amount", donation.amount)
    
    changeset =
      donation
      |> Content.change_donation(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"donation" => donation_params}, socket) do
    donation = socket.assigns.selected_donation
    
    # Always preserve the original amount - it cannot be changed
    params = Map.put(donation_params, "amount", donation.amount)
    
    case Content.update_donation(donation, params) do
      {:ok, donation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Donation updated successfully")
         |> reload_donations()
         |> assign(pending_donations_count: Content.count_pending_donations())
         |> push_navigate(to: ~p"/admin/donations/#{donation.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp parse_page(%{"page" => page}) when is_binary(page) do
    case Integer.parse(page) do
      {page_num, _} when page_num > 0 -> page_num
      _ -> 1
    end
  end

  defp parse_page(_), do: 1

  defp parse_filters(params, current_filters) do
    %{
      status: Map.get(params, "status", current_filters[:status] || "all"),
      payment_method: Map.get(params, "payment_method", current_filters[:payment_method] || "all"),
      search: Map.get(params, "search", current_filters[:search] || ""),
      date_from: parse_date(params, "date_from", current_filters[:date_from]),
      date_to: parse_date(params, "date_to", current_filters[:date_to])
    }
  end

  defp parse_date(params, key, default) do
    case Map.get(params, key) do
      nil -> default
      "" -> nil
      date_str when is_binary(date_str) ->
        case Date.from_iso8601(date_str) do
          {:ok, date} -> date
          _ -> default
        end
      _ -> default
    end
  end

  def build_patch_path(page, filters) do
    params = %{
      "page" => Integer.to_string(page),
      "status" => filters.status,
      "payment_method" => filters.payment_method,
      "search" => filters.search
    }

    params =
      if filters.date_from do
        Map.put(params, "date_from", Date.to_iso8601(filters.date_from))
      else
        params
      end

    params =
      if filters.date_to do
        Map.put(params, "date_to", Date.to_iso8601(filters.date_to))
      else
        params
      end

    ~p"/admin/donations?#{params}"
  end

  defp reload_donations(socket) do
    pagination_opts = [
      page: socket.assigns.page,
      per_page: @per_page,
      status: socket.assigns.filters.status,
      payment_method: socket.assigns.filters.payment_method,
      search: socket.assigns.filters.search,
      date_from: socket.assigns.filters.date_from,
      date_to: socket.assigns.filters.date_to
    ]

    pagination = Content.list_donations_paginated(pagination_opts)

    socket
    |> assign(:pagination, pagination)
    |> assign(:donations, pagination.entries)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

  def page_range_helper(current_page, total_pages) do
    # Show up to 7 page numbers around current page
    start_page = max(1, min(current_page - 3, total_pages - 6))
    end_page = min(total_pages, start_page + 6)
    Enum.to_list(start_page..end_page)
  end
end

