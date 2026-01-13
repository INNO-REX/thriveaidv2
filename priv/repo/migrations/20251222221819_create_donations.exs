defmodule Thriveaidv2.Repo.Migrations.CreateDonations do
  use Ecto.Migration

  def change do
    create table(:donations) do
      add :donor_name, :string, null: false
      add :donor_email, :string, null: false
      add :donor_phone, :string
      add :donor_message, :text
      add :amount, :integer, null: false
      add :payment_method, :string, null: false
      add :status, :string, null: false, default: "pending"

      timestamps(type: :utc_datetime)
    end

    create index(:donations, [:status])
    create index(:donations, [:inserted_at])
  end
end
