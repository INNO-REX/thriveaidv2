defmodule Thriveaidv2.Repo.Migrations.CreateSuccessStories do
  use Ecto.Migration

  def change do
    create table(:success_stories) do
      add :title, :string, null: false
      add :subtitle, :string
      add :summary, :text, null: false
      add :body_html, :text, null: false
      add :cover_image_path, :string
      add :gallery_image_paths, {:array, :string}, null: false, default: []
      add :slug, :string, null: false
      add :is_published, :boolean, null: false, default: false
      add :published_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:success_stories, [:slug])
    create index(:success_stories, [:is_published])
    create index(:success_stories, [:published_at])
  end
end


