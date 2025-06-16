defmodule Thriveaidv2Web.GalleryLive do
  use Thriveaidv2Web, :live_view

  def mount(_params, _session, socket) do
    images = [
      %{
        id: 1,
        url: "/images/24.JPG",
        title: "Academic Support",
        description: "Engaged students participating in our academic support program"
      },
      %{
        id: 2,
        url: "/images/20.jpg",
        title: "Entrepreneurship Training",
        description: "Youth learning practical skills in t-shirt printing"
      },
      %{
        id: 3,
        url: "/images/25.jpeg",
        title: "Skills Development",
        description: "Hands-on training session for practical skills"
      },
      %{
        id: 4,
        url: "/images/8.JPG",
        title: "Group Counseling",
        description: "Supportive group counseling session in progress"
      },
      %{
        id: 5,
        url: "/images/22.jpg",
        title: "Health Education",
        description: "Open discussion on adolescent health and wellness"
      },
      %{
        id: 6,
        url: "/images/img1.jpg",
        title: "Community Impact",
        description: "Making a difference in the lives of young people"
      },
      %{
        id: 7,
        url: "/images/img2.jpg",
        title: "Youth Empowerment",
        description: "Building future leaders through mentorship and support"
      },
      %{
        id: 8,
        url: "/images/home4.jpg",
        title: "Community Programs",
        description: "Engaging youth in meaningful community activities"
      },
      %{
        id: 9,
        url: "/images/23.jpg",
        title: "Community Engagement",
        description: "Building strong relationships with the community"
      },
      %{
        id: 10,
        url: "/images/19.JPG",
        title: "Program Activities",
        description: "Active participation in community development programs"
      },
      %{
        id: 11,
        url: "/images/fountain.jpeg",
        title: "Fountain of Hope",
        description: "Our partnership with Fountain of Hope community"
      },
      %{
        id: 12,
        url: "/images/13.jpg",
        title: "Youth Development",
        description: "Nurturing young talents and leadership skills"
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
