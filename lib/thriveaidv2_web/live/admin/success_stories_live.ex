defmodule Thriveaidv2Web.Admin.SuccessStoriesLive do
  use Thriveaidv2Web, :admin_live_view

  alias Phoenix.LiveView.JS

  alias Thriveaidv2.Content
  alias Thriveaidv2.Content.SuccessStory
  alias Thriveaidv2Web.Uploads

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: "admin")
     |> assign(admin_section: :success_stories)
     |> assign(confirm_delete: nil)
     |> allow_upload(:cover_image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1
     )
     |> allow_upload(:gallery_images,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 12
     )
     |> stream(:success_stories, Content.list_success_stories())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"success_story" => params}, socket) do
    changeset =
      socket.assigns.success_story
      |> Content.change_success_story(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"success_story" => params}, socket) do
    params = maybe_put_uploaded_images(socket, params)
    save_success_story(socket, socket.assigns.live_action, params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    story = Content.get_success_story!(id)
    {:ok, _} = Content.delete_success_story(story)

    {:noreply, stream_delete(socket, :success_stories, story)}
  end

  @impl true
  def handle_event("ask-delete", %{"id" => id}, socket) do
    story = Content.get_success_story!(id)
    {:noreply, assign(socket, confirm_delete: %{id: story.id, title: story.title})}
  end

  @impl true
  def handle_event("confirm-delete", _params, socket) do
    %{id: id} = socket.assigns.confirm_delete
    story = Content.get_success_story!(id)
    {:ok, _} = Content.delete_success_story(story)

    {:noreply,
     socket
     |> assign(confirm_delete: nil)
     |> stream_delete(:success_stories, story)}
  end

  @impl true
  def handle_event("cancel-delete", _params, socket) do
    {:noreply, assign(socket, confirm_delete: nil)}
  end

  @impl true
  def handle_event("toggle-publish", %{"id" => id}, socket) do
    story = Content.get_success_story!(id)

    case Content.update_success_story(story, %{is_published: !story.is_published}) do
      {:ok, story} ->
        {:noreply, stream_insert(socket, :success_stories, story)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update publish status.")}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref, "name" => name}, socket) do
    upload =
      case name do
        "cover_image" -> :cover_image
        "gallery_images" -> :gallery_images
        _ -> :cover_image
      end

    {:noreply, cancel_upload(socket, upload, ref)}
  end

  @impl true
  def handle_event("remove-image", %{"type" => "cover", "path" => path}, socket) do
    removed = Map.get(socket.assigns, :removed_images, [])
    removed = [path | removed] |> Enum.uniq()

    story =
      case socket.assigns[:success_story] do
        %SuccessStory{} = s -> %SuccessStory{s | cover_image_path: nil}
        _ -> socket.assigns[:success_story]
      end

    {:noreply,
     socket
     |> assign(removed_images: removed)
     |> assign(success_story: story)}
  end

  @impl true
  def handle_event("remove-image", %{"type" => "gallery", "path" => path}, socket) do
    removed = Map.get(socket.assigns, :removed_images, [])
    removed = [path | removed] |> Enum.uniq()

    story =
      case socket.assigns[:success_story] do
        %SuccessStory{} = s ->
          gallery = (s.gallery_image_paths || []) |> List.delete(path)
          %SuccessStory{s | gallery_image_paths: gallery}

        _ ->
          socket.assigns[:success_story]
      end

    {:noreply,
     socket
     |> assign(removed_images: removed)
     |> assign(success_story: story)}
  end

  defp maybe_put_uploaded_images(socket, params) do
    removed = Map.get(socket.assigns, :removed_images, [])

    cover_paths =
      consume_uploaded_entries(socket, :cover_image, fn meta, entry ->
        {public_path, _disk_path} = Uploads.persist_uploaded_file!(meta, entry)
        {:ok, public_path}
      end)

    params =
      case cover_paths do
        [path | _] -> Map.put(params, "cover_image_path", path)
        _ ->
          # If no new cover uploaded but cover was removed, clear it
          if socket.assigns[:success_story] && socket.assigns[:success_story].cover_image_path in removed do
            Map.put(params, "cover_image_path", nil)
          else
            params
          end
      end

    new_gallery_paths =
      consume_uploaded_entries(socket, :gallery_images, fn meta, entry ->
        {public_path, _disk_path} = Uploads.persist_uploaded_file!(meta, entry)
        {:ok, public_path}
      end)

    existing =
      case socket.assigns[:success_story] do
        %SuccessStory{} = story -> story.gallery_image_paths || []
        _ -> []
      end

    # Filter out removed images and merge with new uploads
    filtered_existing = existing |> Enum.reject(&(&1 in removed))
    final_gallery = filtered_existing ++ new_gallery_paths

    Map.put(params, "gallery_images_csv", Enum.join(final_gallery, ", "))
  end

  defp save_success_story(socket, :new, params) do
    case Content.create_success_story(params) do
      {:ok, story} ->
        {:noreply,
         socket
         |> stream_insert(:success_stories, story, at: 0)
         |> put_flash(:info, "Success story created.")
         |> push_patch(to: ~p"/admin/success-stories")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_success_story(socket, :edit, params) do
    case Content.update_success_story(socket.assigns.success_story, params) do
      {:ok, story} ->
        {:noreply,
         socket
         |> stream_insert(:success_stories, story)
         |> put_flash(:info, "Success story updated.")
         |> push_patch(to: ~p"/admin/success-stories")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    story = Content.get_success_story!(id) |> story_for_form()

    socket
    |> assign(page_title: "Edit Success Story")
    |> assign(success_story: story)
    |> assign(removed_images: [])
    |> assign_form(Content.change_success_story(story))
  end

  defp apply_action(socket, :new, _params) do
    story = story_for_form(%SuccessStory{})

    socket
    |> assign(page_title: "New Success Story")
    |> assign(success_story: story)
    |> assign(removed_images: [])
    |> assign_form(Content.change_success_story(story))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(page_title: "Success Stories")
    |> assign(success_story: nil, form: nil)
  end

  defp story_for_form(%SuccessStory{} = story) do
    csv = Enum.join(story.gallery_image_paths || [], ", ")
    %SuccessStory{
      story
      | gallery_images_csv: csv,
        body_html: Thriveaidv2Web.TextHelpers.html_to_text(story.body_html || "")
    }
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

  defp close_modal_js do
    JS.patch(~p"/admin/success-stories")
  end
end


