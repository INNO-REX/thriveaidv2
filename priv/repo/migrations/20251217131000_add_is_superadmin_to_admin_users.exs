defmodule Thriveaidv2.Repo.Migrations.AddIsSuperadminToAdminUsers do
  use Ecto.Migration

  def change do
    alter table(:admin_users) do
      add :is_superadmin, :boolean, default: false, null: false
    end

    create index(:admin_users, [:is_superadmin])
  end
end


