defmodule Thriveaidv2Web.GalleryLive do
  use Thriveaidv2Web, :live_view

  def mount(_params, _session, socket) do
    images = [
      %{
        id: 1,
        url: "/images/gallery/image1.jpg",
        title: "Community Education",
        description: "Empowering through knowledge and skills development"
      },
      %{
        id: 2,
        url: "/images/gallery/image2.jpg",
        title: "Healthcare Initiatives",
        description: "Providing essential medical services to communities"
      },
      %{
        id: 3,
        url: "/images/gallery/image3.jpg",
        title: "Sustainable Agriculture",
        description: "Supporting local farmers and food security"
      },
      %{
        id: 4,
        url: "/images/gallery/image4.jpg",
        title: "Clean Water Projects",
        description: "Ensuring access to safe drinking water"
      },
      %{
        id: 5,
        url: "/images/gallery/image5.jpg",
        title: "Youth Empowerment",
        description: "Building future leaders through mentorship"
      },
      %{
        id: 6,
        url: "/images/gallery/image6.jpg",
        title: "Women's Programs",
        description: "Supporting women entrepreneurs and leaders"
      }
    ]

    {:ok, assign(socket, images: images, selected_image: nil)}
  end

  def handle_event("select-image", %{"id" => id}, socket) do
    id = String.to_integer(id)
    selected_image = Enum.find(socket.assigns.images, &(&1.id == id))
    {:noreply, assign(socket, selected_image: selected_image)}
  end

  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, selected_image: nil)}
  end
end
