defmodule Thriveaidv2.Repo.Migrations.AddPermissionsToAdminUsers do
  use Ecto.Migration

  def change do
    alter table(:admin_users) do
      add :permissions, {:array, :string}, default: [], null: false
    end

    # Efficient permission checks for Postgres array containment queries
    create index(:admin_users, [:permissions], using: :gin)

    execute("""
    UPDATE admin_users
    SET permissions = ARRAY['manage_content','manage_messages']
    WHERE is_superadmin = FALSE OR is_superadmin IS NULL
    """)

    execute("""
    UPDATE admin_users
    SET permissions = ARRAY['manage_admins','manage_content','manage_messages']
    WHERE is_superadmin = TRUE
    """)
  end
end


