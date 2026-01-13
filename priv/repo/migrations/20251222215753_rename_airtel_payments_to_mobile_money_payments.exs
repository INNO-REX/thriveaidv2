defmodule Thriveaidv2.Repo.Migrations.RenameAirtelPaymentsToMobileMoneyPayments do
  use Ecto.Migration

  def change do
    rename table(:airtel_payments), to: table(:mobile_money_payments)
    
    alter table(:mobile_money_payments) do
      add :method_name, :string, null: false, default: "airtel"
    end
    
    create unique_index(:mobile_money_payments, [:method_name])
    
    # Update existing record to have method_name
    execute "UPDATE mobile_money_payments SET method_name = 'airtel' WHERE method_name IS NULL OR method_name = ''"
  end
end
