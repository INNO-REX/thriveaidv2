defmodule Thriveaidv2Web.Admin.PartnersLive do
  use Thriveaidv2Web, :admin_live_view

  alias Phoenix.LiveView.JS

  alias Thriveaidv2.Content
  alias Thriveaidv2.Content.Partner
  alias Thriveaidv2Web.Uploads
  alias Thriveaidv2Web.ImageProcessor

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: "admin")
     |> assign(admin_section: :partners)
     |> assign(confirm_delete: nil)
     |> allow_upload(:logo,
       accept: ~w(.jpg .jpeg .png .webp .svg),
       max_entries: 1
     )
     |> stream(:partners, Content.list_partners())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"partner" => params}, socket) do
    changeset =
      socket.assigns.partner
      |> Content.change_partner(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"partner" => params}, socket) do
    params = maybe_put_uploaded_logo(socket, params)
    save_partner(socket, socket.assigns.live_action, params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    partner = Content.get_partner!(id)
    {:ok, _} = Content.delete_partner(partner)

    {:noreply, stream_delete(socket, :partners, partner)}
  end

  @impl true
  def handle_event("ask-delete", %{"id" => id}, socket) do
    partner = Content.get_partner!(id)
    {:noreply, assign(socket, confirm_delete: %{id: partner.id, name: partner.name})}
  end

  @impl true
  def handle_event("confirm-delete", _params, socket) do
    %{id: id} = socket.assigns.confirm_delete
    partner = Content.get_partner!(id)
    {:ok, _} = Content.delete_partner(partner)

    {:noreply,
     socket
     |> assign(confirm_delete: nil)
     |> stream_delete(:partners, partner)}
  end

  @impl true
  def handle_event("cancel-delete", _params, socket) do
    {:noreply, assign(socket, confirm_delete: nil)}
  end

  @impl true
  def handle_event("toggle-active", %{"id" => id}, socket) do
    partner = Content.get_partner!(id)

    case Content.update_partner(partner, %{is_active: !partner.is_active}) do
      {:ok, partner} ->
        {:noreply, stream_insert(socket, :partners, partner)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update active status.")}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :logo, ref)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    partner = Content.get_partner!(id)

    socket
    |> assign(:page_title, "Edit Partner")
    |> assign(:partner, partner)
    |> assign_form(Content.change_partner(partner))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Partner")
    |> assign(:partner, %Partner{})
    |> assign_form(Content.change_partner(%Partner{}))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Partners")
    |> assign(:partner, nil)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp save_partner(socket, :edit, params) do
    case Content.update_partner(socket.assigns.partner, params) do
      {:ok, partner} ->
        notify_parent({:saved, partner})

        {:noreply,
         socket
         |> put_flash(:info, "Partner updated successfully")
         |> stream_insert(:partners, partner)
         |> push_patch(to: ~p"/admin/partners")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_partner(socket, :new, params) do
    case Content.create_partner(params) do
      {:ok, partner} ->
        notify_parent({:saved, partner})

        {:noreply,
         socket
         |> put_flash(:info, "Partner created successfully")
         |> stream_insert(:partners, partner, at: 0)
         |> push_patch(to: ~p"/admin/partners")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp maybe_put_uploaded_logo(socket, params) do
    logo_paths =
      consume_uploaded_entries(socket, :logo, fn meta, entry ->
        {public_path, disk_path} = Uploads.persist_uploaded_file!(meta, entry)
        
        # Skip background removal for SVG files (they're already vector graphics)
        ext = Path.extname(disk_path) |> String.downcase()
        if ext == ".svg" do
          {:ok, public_path}
        else
          # Remove background from the uploaded image
          case ImageProcessor.remove_background(disk_path) do
            {:ok, processed_path} ->
              # Verify processed file exists and is valid before replacing original
              if File.exists?(processed_path) do
                file_size = File.stat!(processed_path).size
                if file_size > 0 do
                  # Update paths to use .png extension
                  new_public_path = public_path |> Path.rootname() |> Kernel.<>(".png")
                  new_disk_path = disk_path |> Path.rootname() |> Kernel.<>(".png")
                  
                  # Delete original file only after confirming processed file is valid
                  File.rm!(disk_path)
                  
                  # Move processed file to final location
                  File.rename!(processed_path, new_disk_path)
                  {:ok, new_public_path}
                else
                  # Processed file is empty, keep original
                  require Logger
                  Logger.warning("Processed image file is empty, keeping original")
                  # Clean up invalid processed file
                  File.rm(processed_path)
                  {:ok, public_path}
                end
              else
                # Processed file doesn't exist, keep original
                require Logger
                Logger.warning("Processed image file was not created, keeping original")
                {:ok, public_path}
              end
            
            {:error, reason} ->
              # Log error but continue with original image
              require Logger
              Logger.warning("Failed to remove background from partner logo: #{reason}. Using original image.")
              {:ok, public_path}
          end
        end
      end)

    case logo_paths do
      [path | _] -> Map.put(params, "logo_path", path)
      _ -> params
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp close_modal_js do
    JS.patch(~p"/admin/partners")
  end
end

