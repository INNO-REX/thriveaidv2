defmodule Thriveaidv2.Repo.Migrations.CreateContactMessages do
  use Ecto.Migration

  def change do
    create table(:contact_messages) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :subject, :string, null: false
      add :message, :text, null: false
      add :is_read, :boolean, null: false, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:contact_messages, [:is_read])
    create index(:contact_messages, [:inserted_at])
  end
end


