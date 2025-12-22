defmodule Thriveaidv2.Repo.Migrations.AddReplyFieldsToContactMessages do
  use Ecto.Migration

  def change do
    alter table(:contact_messages) do
      add :reply_subject, :string
      add :reply_body, :text
      add :replied_at, :utc_datetime
      add :replied_by_admin_user_id, references(:admin_users, on_delete: :nilify_all)
    end

    create index(:contact_messages, [:replied_at])
    create index(:contact_messages, [:replied_by_admin_user_id])
  end
end


