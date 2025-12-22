defmodule Thriveaidv2Web.Admin.NewsPostsLive do
  use Thriveaidv2Web, :admin_live_view

  alias Phoenix.LiveView.JS

  alias Thriveaidv2.Content
  alias Thriveaidv2.Content.NewsPost
  alias Thriveaidv2Web.Uploads

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: "admin")
     |> assign(admin_section: :news)
     |> assign(confirm_delete: nil)
     |> allow_upload(:cover_image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1
     )
     |> allow_upload(:images,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 12
     )
     |> stream(:news_posts, Content.list_news_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"news_post" => params}, socket) do
    changeset =
      socket.assigns.news_post
      |> Content.change_news_post(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"news_post" => params}, socket) do
    params = maybe_put_uploaded_images(socket, params)
    save_news_post(socket, socket.assigns.live_action, params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Content.get_news_post!(id)
    {:ok, _} = Content.delete_news_post(post)

    {:noreply, stream_delete(socket, :news_posts, post)}
  end

  @impl true
  def handle_event("ask-delete", %{"id" => id}, socket) do
    post = Content.get_news_post!(id)
    {:noreply, assign(socket, confirm_delete: %{id: post.id, title: post.title})}
  end

  @impl true
  def handle_event("confirm-delete", _params, socket) do
    %{id: id} = socket.assigns.confirm_delete
    post = Content.get_news_post!(id)
    {:ok, _} = Content.delete_news_post(post)

    {:noreply,
     socket
     |> assign(confirm_delete: nil)
     |> stream_delete(:news_posts, post)}
  end

  @impl true
  def handle_event("cancel-delete", _params, socket) do
    {:noreply, assign(socket, confirm_delete: nil)}
  end

  @impl true
  def handle_event("toggle-publish", %{"id" => id}, socket) do
    post = Content.get_news_post!(id)

    case Content.update_news_post(post, %{is_published: !post.is_published}) do
      {:ok, post} ->
        {:noreply, stream_insert(socket, :news_posts, post)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update publish status.")}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref, "name" => name}, socket) do
    upload =
      case name do
        "cover_image" -> :cover_image
        "images" -> :images
        _ -> :cover_image
      end

    {:noreply, cancel_upload(socket, upload, ref)}
  end

  @impl true
  def handle_event("remove-image", %{"type" => "cover", "path" => path}, socket) do
    removed = Map.get(socket.assigns, :removed_images, [])
    removed = [path | removed] |> Enum.uniq()

    post =
      case socket.assigns[:news_post] do
        %NewsPost{} = p -> %NewsPost{p | cover_image_path: nil}
        _ -> socket.assigns[:news_post]
      end

    {:noreply,
     socket
     |> assign(removed_images: removed)
     |> assign(news_post: post)}
  end

  @impl true
  def handle_event("remove-image", %{"type" => "gallery", "path" => path}, socket) do
    removed = Map.get(socket.assigns, :removed_images, [])
    removed = [path | removed] |> Enum.uniq()

    post =
      case socket.assigns[:news_post] do
        %NewsPost{} = p ->
          images = (p.image_paths || []) |> List.delete(path)
          %NewsPost{p | image_paths: images}

        _ ->
          socket.assigns[:news_post]
      end

    {:noreply,
     socket
     |> assign(removed_images: removed)
     |> assign(news_post: post)}
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
          if socket.assigns[:news_post] && socket.assigns[:news_post].cover_image_path in removed do
            Map.put(params, "cover_image_path", nil)
          else
            params
          end
      end

    new_paths =
      consume_uploaded_entries(socket, :images, fn meta, entry ->
        {public_path, _disk_path} = Uploads.persist_uploaded_file!(meta, entry)
        {:ok, public_path}
      end)

    existing =
      case socket.assigns[:news_post] do
        %NewsPost{} = post -> post.image_paths || []
        _ -> []
      end

    # Filter out removed images and merge with new uploads
    filtered_existing = existing |> Enum.reject(&(&1 in removed))
    final_images = filtered_existing ++ new_paths

    Map.put(params, "image_paths_csv", Enum.join(final_images, ", "))
  end

  defp save_news_post(socket, :new, params) do
    case Content.create_news_post(params) do
      {:ok, post} ->
        {:noreply,
         socket
         |> stream_insert(:news_posts, post, at: 0)
         |> put_flash(:info, "News post created.")
         |> push_patch(to: ~p"/admin/news")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_news_post(socket, :edit, params) do
    case Content.update_news_post(socket.assigns.news_post, params) do
      {:ok, post} ->
        {:noreply,
         socket
         |> stream_insert(:news_posts, post)
         |> put_flash(:info, "News post updated.")
         |> push_patch(to: ~p"/admin/news")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Content.get_news_post!(id) |> post_for_form()

    socket
    |> assign(page_title: "Edit News Post")
    |> assign(news_post: post)
    |> assign(removed_images: [])
    |> assign_form(Content.change_news_post(post))
  end

  defp apply_action(socket, :new, _params) do
    post = post_for_form(%NewsPost{})

    socket
    |> assign(page_title: "New News Post")
    |> assign(news_post: post)
    |> assign(removed_images: [])
    |> assign_form(Content.change_news_post(post))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(page_title: "News Updates")
    |> assign(news_post: nil, form: nil)
  end

  defp post_for_form(%NewsPost{} = post) do
    csv = Enum.join(post.image_paths || [], ", ")
    %NewsPost{
      post
      | image_paths_csv: csv,
        body_html: Thriveaidv2Web.TextHelpers.html_to_text(post.body_html || "")
    }
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

  defp close_modal_js do
    JS.patch(~p"/admin/news")
  end
end


