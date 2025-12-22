defmodule Thriveaidv2.Content.NewsPost do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "news_posts" do
    field :title, :string
    field :date_label, :string
    field :summary, :string
    field :body_html, :string
    field :cover_image_path, :string
    field :image_paths, {:array, :string}, default: []
    field :slug, :string
    field :is_published, :boolean, default: false
    field :published_at, :utc_datetime

    # Admin form helper
    field :image_paths_csv, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :title,
      :date_label,
      :summary,
      :body_html,
      :cover_image_path,
      :slug,
      :is_published,
      :published_at,
      :image_paths_csv
    ])
    |> validate_required([:title, :summary, :body_html])
    |> validate_length(:title, max: 255)
    |> validate_length(:date_label, max: 50)
    |> maybe_put_slug()
    |> maybe_put_image_paths(attrs)
    |> maybe_put_published_at()
    |> unique_constraint(:slug)
  end

  defp maybe_put_slug(changeset) do
    slug = get_field(changeset, :slug)

    if is_binary(slug) and String.trim(slug) != "" do
      changeset
    else
      title = get_field(changeset, :title) || ""
      put_change(changeset, :slug, slugify(title))
    end
  end

  defp maybe_put_image_paths(changeset, attrs) do
    csv =
      cond do
        is_map(attrs) && Map.has_key?(attrs, "image_paths_csv") -> Map.get(attrs, "image_paths_csv")
        is_map(attrs) && Map.has_key?(attrs, :image_paths_csv) -> Map.get(attrs, :image_paths_csv)
        true -> nil
      end

    if is_binary(csv) do
      paths =
        csv
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))

      changeset
      |> put_change(:image_paths, paths)
      |> put_change(:image_paths_csv, Enum.join(paths, ", "))
    else
      changeset
    end
  end

  defp maybe_put_published_at(changeset) do
    is_published = get_field(changeset, :is_published)
    published_at = get_field(changeset, :published_at)

    cond do
      is_published == true and is_nil(published_at) ->
        put_change(changeset, :published_at, DateTime.utc_now() |> DateTime.truncate(:second))

      is_published == false ->
        put_change(changeset, :published_at, nil)

      true ->
        changeset
    end
  end

  defp slugify(str) when is_binary(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/u, "")
    |> String.replace(~r/[\s_-]+/u, "-")
    |> String.trim("-")
  end
end


