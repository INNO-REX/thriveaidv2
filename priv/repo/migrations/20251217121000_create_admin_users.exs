defmodule Thriveaidv2.Repo.Migrations.CreateAdminUsers do
  use Ecto.Migration

  def change do
    create table(:admin_users) do
      add :email, :string, null: false
      add :name, :string
      add :hashed_password, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:admin_users, [:email])
  end
end


