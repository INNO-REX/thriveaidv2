defmodule Thriveaidv2.Repo.Migrations.CreateNewsPosts do
  use Ecto.Migration

  def change do
    create table(:news_posts) do
      add :title, :string, null: false
      add :date_label, :string
      add :summary, :text, null: false
      add :body_html, :text, null: false
      add :cover_image_path, :string
      add :image_paths, {:array, :string}, null: false, default: []
      add :slug, :string, null: false
      add :is_published, :boolean, null: false, default: false
      add :published_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:news_posts, [:slug])
    create index(:news_posts, [:is_published])
    create index(:news_posts, [:published_at])
  end
end


