defmodule Thriveaidv2.Repo.Migrations.CreateAirtelPayments do
  use Ecto.Migration

  def change do
    create table(:airtel_payments) do
      add :phone_number, :string, null: false
      add :account_name, :string, null: false
      add :payment_steps_html, :text, null: false

      timestamps(type: :utc_datetime)
    end
  end
end

