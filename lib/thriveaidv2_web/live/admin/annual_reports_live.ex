defmodule Thriveaidv2Web.Admin.AnnualReportsLive do
  use Thriveaidv2Web, :admin_live_view

  alias Thriveaidv2.Content
  alias Thriveaidv2.Content.AnnualReport
  alias Thriveaidv2Web.Uploads

  @impl true
  def mount(_params, _session, socket) do
    reports = Content.list_annual_reports()
    latest_published = Content.get_latest_published_annual_report()
    history_reports = 
      reports
      |> Enum.reject(fn r -> latest_published && r.id == latest_published.id end)
    
    {:ok,
     socket
     |> assign(current_page: "admin")
     |> assign(admin_section: :annual_reports)
     |> assign(confirm_delete: nil)
     |> assign(annual_report: nil)
     |> assign(form: nil)
     |> assign(remove_pdf: false)
     |> assign(reports_count: length(reports))
     |> assign(latest_published: latest_published)
     |> assign(history_reports: history_reports)
     |> allow_upload(:pdf,
       accept: ~w(.pdf),
       max_entries: 1,
       max_file_size: 10_000_000,
       auto_upload: true
     )
     |> stream(:annual_reports, reports)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"annual_report" => params}, socket) do
    require Logger
    changeset =
      socket.assigns.annual_report
      |> Content.change_annual_report(params)
      |> Map.put(:action, :validate)

    if changeset.errors != [] do
      Logger.debug("Validation errors: #{inspect(changeset.errors)}")
    end

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"annual_report" => params}, socket) do
    require Logger
    Logger.debug("Save event received with params: #{inspect(params)}")
    Logger.debug("Live action: #{inspect(socket.assigns.live_action)}")
    
    # Normalize checkbox value - Phoenix forms send "true" string when checked, nothing when unchecked
    params = 
      case Map.get(params, "is_published") do
        "true" -> Map.put(params, "is_published", true)
        true -> params
        _ -> Map.put(params, "is_published", false)
      end
    
    Logger.debug("Params after checkbox normalization: #{inspect(params)}")
    params = maybe_put_uploaded_pdf(socket, params)
    Logger.debug("Params after PDF processing: #{inspect(params)}")
    save_annual_report(socket, socket.assigns.live_action, params)
  end

  def handle_event("save", params, socket) do
    require Logger
    Logger.error("Save event received with unexpected params: #{inspect(params)}")
    {:noreply, put_flash(socket, :error, "Form submission error. Please try again.")}
  end

  @impl true
  def handle_event("toggle-publish", %{"id" => id}, socket) do
    annual_report = Content.get_annual_report!(id)
    new_published_status = !annual_report.is_published

    # If publishing, unpublish all other reports first
    socket = if new_published_status do
      # Get all published reports before unpublishing
      published_reports = Content.list_published_annual_reports()
      unpublish_other_reports(id)
      
      # Update the stream for all unpublished reports
      Enum.reduce(published_reports, socket, fn report, acc ->
        updated_report = %{report | is_published: false, published_at: nil}
        stream_insert(acc, :annual_reports, updated_report)
      end)
    else
      socket
    end

    case Content.update_annual_report(annual_report, %{is_published: new_published_status}) do
      {:ok, updated_report} ->
        # Refresh the latest published and history lists
        reports = Content.list_annual_reports()
        latest_published = Content.get_latest_published_annual_report()
        history_reports = 
          reports
          |> Enum.reject(fn r -> latest_published && r.id == latest_published.id end)
        
        {:noreply,
         socket
         |> stream_insert(:annual_reports, updated_report)
         |> assign(latest_published: latest_published)
         |> assign(history_reports: history_reports)
         |> put_flash(:info, if(updated_report.is_published, do: "Report published.", else: "Report unpublished."))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update publish status.")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    annual_report = Content.get_annual_report!(id)
    {:ok, _} = Content.delete_annual_report(annual_report)

    {:noreply, stream_delete(socket, :annual_reports, annual_report)}
  end

  @impl true
  def handle_event("ask-delete", %{"id" => id}, socket) do
    annual_report = Content.get_annual_report!(id)
    {:noreply, assign(socket, confirm_delete: %{id: annual_report.id, title: annual_report.title})}
  end

  @impl true
  def handle_event("confirm-delete", _params, socket) do
    %{id: id} = socket.assigns.confirm_delete
    annual_report = Content.get_annual_report!(id)
    {:ok, _} = Content.delete_annual_report(annual_report)

    {:noreply,
     socket
     |> assign(confirm_delete: nil)
     |> update(:reports_count, fn count -> max(0, count - 1) end)
     |> stream_delete(:annual_reports, annual_report)}
  end

  @impl true
  def handle_event("cancel-delete", _params, socket) do
    {:noreply, assign(socket, confirm_delete: nil)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :pdf, ref)}
  end

  @impl true
  def handle_event("remove-pdf", _params, socket) do
    {:noreply, assign(socket, remove_pdf: true)}
  end

  defp save_annual_report(socket, :new, params) do
    require Logger
    Logger.debug("Creating annual report with params: #{inspect(params)}")
    
    # If publishing a new report, unpublish the previous one
    socket = if Map.get(params, "is_published") == true do
      # Get all published reports before unpublishing
      published_reports = Content.list_published_annual_reports()
      unpublish_other_reports()
      
      # Update the stream for all unpublished reports
      Enum.reduce(published_reports, socket, fn report, acc ->
        updated_report = %{report | is_published: false, published_at: nil}
        stream_insert(acc, :annual_reports, updated_report)
      end)
    else
      socket
    end
    
    case Content.create_annual_report(params) do
      {:ok, annual_report} ->
        Logger.debug("Annual report created successfully: #{annual_report.id}")
        
        # Refresh the latest published and history lists
        reports = Content.list_annual_reports()
        latest_published = Content.get_latest_published_annual_report()
        history_reports = 
          reports
          |> Enum.reject(fn r -> latest_published && r.id == latest_published.id end)
        
        {:noreply,
         socket
         |> stream_insert(:annual_reports, annual_report, at: 0)
         |> update(:reports_count, fn count -> count + 1 end)
         |> assign(latest_published: latest_published)
         |> assign(history_reports: history_reports)
         |> put_flash(:info, "Annual report created.")
         |> push_patch(to: ~p"/admin/annual-reports")}

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Failed to create annual report. Errors: #{inspect(changeset.errors)}")
        {:noreply,
         socket
         |> assign_form(changeset)
         |> put_flash(:error, "Please fix the errors below.")}
    end
  end

  defp save_annual_report(socket, :edit, params) do
    params = if socket.assigns[:remove_pdf], do: Map.put(params, "pdf_path", nil), else: params

    # If publishing this report, unpublish all other reports
    current_report = socket.assigns.annual_report
    is_publishing = Map.get(params, "is_published") == true
    was_published = current_report.is_published == true
    
    socket = if is_publishing && !was_published do
      # Get all published reports before unpublishing
      published_reports = Content.list_published_annual_reports()
      unpublish_other_reports(current_report.id)
      
      # Update the stream for all unpublished reports
      Enum.reduce(published_reports, socket, fn report, acc ->
        updated_report = %{report | is_published: false, published_at: nil}
        stream_insert(acc, :annual_reports, updated_report)
      end)
    else
      socket
    end

    case Content.update_annual_report(current_report, params) do
      {:ok, annual_report} ->
        # Refresh the latest published and history lists
        reports = Content.list_annual_reports()
        latest_published = Content.get_latest_published_annual_report()
        history_reports = 
          reports
          |> Enum.reject(fn r -> latest_published && r.id == latest_published.id end)
        
        {:noreply,
         socket
         |> stream_insert(:annual_reports, annual_report)
         |> assign(latest_published: latest_published)
         |> assign(history_reports: history_reports)
         |> put_flash(:info, "Annual report updated.")
         |> push_patch(to: ~p"/admin/annual-reports")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign_form(changeset)
         |> put_flash(:error, "Please fix the errors below.")}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    annual_report = Content.get_annual_report!(id)

    socket
    |> assign(page_title: "Edit Annual Report")
    |> assign(annual_report: annual_report)
    |> assign(remove_pdf: false)
    |> assign_form(Content.change_annual_report(annual_report))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(page_title: "New Annual Report")
    |> assign(annual_report: %AnnualReport{})
    |> assign(remove_pdf: false)
    |> assign_form(Content.change_annual_report(%AnnualReport{}))
  end

  defp apply_action(socket, :index, _params) do
    reports = Content.list_annual_reports()
    socket
    |> assign(page_title: "Annual Reports")
    |> assign(annual_report: nil, form: nil)
    |> assign(reports_count: length(reports))
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

  defp unpublish_other_reports(exclude_id \\ nil) do
    alias Thriveaidv2.Repo
    alias Thriveaidv2.Content.AnnualReport
    import Ecto.Query

    query = from(a in AnnualReport, where: a.is_published == true)
    query = if exclude_id, do: from(a in query, where: a.id != ^exclude_id), else: query

    Repo.update_all(query, set: [is_published: false, published_at: nil])
  end

  defp maybe_put_uploaded_pdf(socket, params) do
    pdf_paths =
      consume_uploaded_entries(socket, :pdf, fn meta, entry ->
        {public_path, _disk_path} = Uploads.persist_uploaded_file!(meta, entry)
        {:ok, public_path}
      end)

    case pdf_paths do
      [path | _] -> Map.put(params, "pdf_path", path)
      _ -> 
        # If editing and PDF was removed, clear it
        if socket.assigns[:remove_pdf] && socket.assigns[:annual_report] do
          Map.put(params, "pdf_path", nil)
        else
          params
        end
    end
  end

  def format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_000_000 -> "#{Float.round(bytes / 1_000_000, 1)} MB"
      bytes >= 1_000 -> "#{Float.round(bytes / 1_000, 1)} KB"
      true -> "#{bytes} bytes"
    end
  end

  def format_bytes(_), do: "0 bytes"
end

