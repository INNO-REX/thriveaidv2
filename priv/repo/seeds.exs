# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Thriveaidv2.Repo.insert!(%Thriveaidv2.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query, warn: false

alias Thriveaidv2.Repo
alias Thriveaidv2.Accounts
alias Thriveaidv2.Accounts.AdminUser
alias Thriveaidv2.Content
alias Thriveaidv2.Content.NewsPost
alias Thriveaidv2.Content.SuccessStory

admin_user_count = Repo.aggregate(AdminUser, :count, :id)
success_story_count = Repo.aggregate(SuccessStory, :count, :id)
news_post_count = Repo.aggregate(NewsPost, :count, :id)

# Ensure a superadmin exists (for managing other admins)
super_email = System.get_env("SEED_SUPERADMIN_EMAIL") || "vincentlyondo12@gmail.com"
super_password = System.get_env("SEED_SUPERADMIN_PASSWORD") || "vince123"
super_name = System.get_env("SEED_SUPERADMIN_NAME") || "Vincent"
super_permissions = ["manage_admins", "manage_content", "manage_messages"]

case Accounts.get_admin_user_by_email(super_email) do
  nil ->
    Accounts.create_admin_user(%{
      email: super_email,
      password: super_password,
      name: super_name,
      is_superadmin: true,
      permissions: super_permissions
    })

  %AdminUser{} = user ->
    Accounts.update_admin_user(user, %{permissions: super_permissions})

    if Map.get(user, :is_superadmin) != true do
      Accounts.update_admin_user(user, %{is_superadmin: true})
    end
end

if admin_user_count == 0 do
  email = System.get_env("SEED_ADMIN_EMAIL") || "admin@thriveaid.local"
  password = System.get_env("SEED_ADMIN_PASSWORD") || "admin1234"
  name = System.get_env("SEED_ADMIN_NAME") || "Admin"

  Accounts.create_admin_user(%{email: email, password: password, name: name})
end

if success_story_count == 0 do
  Content.create_success_story(%{
    title: "Joseph Mulenga",
    subtitle: "Entrepreneurship Success Story",
    cover_image_path: "/images/Joseph.jpg",
    gallery_images_csv: "/images/joseph-t.jpeg",
    summary:
      "Joseph Mulenga, a resident of Fountain of Hope orphanage, was enrolled in the first cohort of the Ignite Entrepreneurship program by Thrive Aid.",
    body_html: """
    Joseph Mulenga, a resident of Fountain of Hope orphanage, was enrolled in the first cohort of the Ignite Entrepreneurship program by Thrive Aid. The 3 months program aimed to equip young people with entrepreneurship skills and inspire them to become entrepreneurs.

    Joseph embraced the lessons and was motivated to become an entrepreneur himself.

    Joseph began saving small amounts of money until he had saved up K61. With K61 in hand, he decided it was enough to start his business.
    """,
    is_published: true
  })

  Content.create_success_story(%{
    title: "Precious J Banda",
    subtitle: "Educational Transformation",
    cover_image_path: "/images/precious.jpeg",
    gallery_images_csv: "/images/precious-t.jpeg",
    summary: "Precious J Banda's journey is a testament to resilience and the transformative power of education.",
    body_html: """
    Precious J Banda's journey is a testament to resilience and the transformative power of education.

    Despite obstacles, Precious never relented. With Thrive Aid support, she caught up, excelled, and is now pursuing a degree in Clinical Medicine.
    """,
    is_published: true
  })
end

if news_post_count == 0 do
  Content.create_news_post(%{
    title: "Empowering Young People Through Computer Literacy: A Successful Initiative by Thrive Aid",
    date_label: "2024",
    cover_image_path: "/images/news/news1/2.jpg",
    image_paths_csv: "/images/news/news1/6.jpg, /images/news/news1/8.jpg, /images/news/news1/3.jpg, /images/news/news1/9.jpg",
    summary:
      "Thrive Aid launched a transformative Computer Literacy Program aimed at bridging the digital divide for 17 young people.",
    body_html: """
    This holiday season, Thrive Aid launched a transformative Computer Literacy Program as part of our academic support and mentorship initiatives.

    The program, aimed at bridging the digital divide, was held at USAID Open Spaces (Digi Hub).
    """,
    is_published: true
  })

  Content.create_news_post(%{
    title: "Thrive Aid and Ministry of Community Development Join Forces in Street Children Awareness Campaign",
    date_label: "August 2024",
    cover_image_path: "/images/news/news2/4.jpg",
    image_paths_csv: "/images/news/news2/1.jpg, /images/news/news2/8.jpg, /images/news/news2/3.jpg, /images/news/news2/9.jpg",
    summary:
      "Thrive Aid collaborated with the Ministry of Community Development and Social Services to launch a vital public awareness campaign.",
    body_html: """
    This outreach program, held on 15th August 2024, aimed to address a critical issue that affects the lives of many children living on the streets—alms-giving.
    """,
    is_published: true
  })

  Content.create_news_post(%{
    title: "Thrive Aid Brings Hope to the Streets: Mental Health and Adolescent Health Outreach for Young People",
    date_label: "September 2024",
    cover_image_path: "/images/news/news3/1.jpg",
    image_paths_csv: "/images/news/news3/2.jpg, /images/news/news3/3.jpg, /images/news/news3/4.jpg, /images/news/news3/5.jpg",
    summary:
      "Thrive Aid organized a Mental Health Outreach event providing vital support to children living on the streets and those at Fountain of Hope.",
    body_html: """
    On September 7th, Thrive Aid organized a Mental Health Outreach event that provided vital support to children living on the streets and those residing at the Fountain of Hope Orphanage.
    """,
    is_published: true
  })
end