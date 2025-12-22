defmodule Thriveaidv2.Content do
  @moduledoc """
  Content management for ThriveAid: Success Stories and News Posts.
  """

  import Ecto.Query, warn: false

  alias Thriveaidv2.Repo

  alias Thriveaidv2.Content.NewsPost
  alias Thriveaidv2.Content.SuccessStory

  ## Success Stories

  def list_success_stories do
    Repo.all(from s in SuccessStory, order_by: [desc: s.inserted_at])
  end

  def list_published_success_stories do
    Repo.all(
      from s in SuccessStory,
        where: s.is_published == true,
        order_by: [desc: s.published_at, desc: s.inserted_at]
    )
  end

  def get_success_story!(id), do: Repo.get!(SuccessStory, id)

  def create_success_story(attrs \\ %{}) do
    %SuccessStory{}
    |> SuccessStory.changeset(attrs)
    |> Repo.insert()
  end

  def update_success_story(%SuccessStory{} = story, attrs) do
    story
    |> SuccessStory.changeset(attrs)
    |> Repo.update()
  end

  def delete_success_story(%SuccessStory{} = story), do: Repo.delete(story)

  def change_success_story(%SuccessStory{} = story, attrs \\ %{}) do
    SuccessStory.changeset(story, attrs)
  end

  ## News Posts

  def list_news_posts do
    Repo.all(from n in NewsPost, order_by: [desc: n.inserted_at])
  end

  def list_published_news_posts do
    Repo.all(
      from n in NewsPost,
        where: n.is_published == true,
        order_by: [desc: n.published_at, desc: n.inserted_at]
    )
  end

  def get_news_post!(id), do: Repo.get!(NewsPost, id)

  def create_news_post(attrs \\ %{}) do
    %NewsPost{}
    |> NewsPost.changeset(attrs)
    |> Repo.insert()
  end

  def update_news_post(%NewsPost{} = post, attrs) do
    post
    |> NewsPost.changeset(attrs)
    |> Repo.update()
  end

  def delete_news_post(%NewsPost{} = post), do: Repo.delete(post)

  def change_news_post(%NewsPost{} = post, attrs \\ %{}) do
    NewsPost.changeset(post, attrs)
  end
end


