defmodule Thriveaidv2.Repo.Migrations.CreatePartners do
  use Ecto.Migration

  def change do
    create table(:partners) do
      add :name, :string, null: false
      add :logo_path, :string, null: false
      add :website_url, :string
      add :display_order, :integer, null: false, default: 0
      add :is_active, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create index(:partners, [:is_active])
    create index(:partners, [:display_order])
  end
end
