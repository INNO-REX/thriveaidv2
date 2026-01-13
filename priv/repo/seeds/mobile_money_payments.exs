alias Thriveaidv2.Content

# Define payment methods with their specific steps
methods = [
  %{
    method_name: "airtel",
    phone_number: "+260 977 123 456",
    account_name: "ThriveAid Foundation",
    steps: [
      "Dial *123# on your Airtel phone",
      "Select Send Money or Pay Bill from the menu",
      "Enter the phone number: PHONENUMBER",
      "Enter the amount: KAMOUNT",
      "Verify the recipient name shows as: ACCOUNTNAME",
      "Enter your PIN to confirm the transaction"
    ]
  },
  %{
    method_name: "mtn",
    phone_number: "+260 966 123 456",
    account_name: "ThriveAid Foundation",
    steps: [
      "Dial *165# on your MTN phone",
      "Select Send Money from the menu",
      "Enter the phone number: PHONENUMBER",
      "Enter the amount: KAMOUNT",
      "Verify the recipient name shows as: ACCOUNTNAME",
      "Enter your PIN to confirm the transaction"
    ]
  },
  %{
    method_name: "zamtel",
    phone_number: "+260 955 123 456",
    account_name: "ThriveAid Foundation",
    steps: [
      "Dial *115# on your Zamtel phone",
      "Select Send Money from the menu",
      "Enter the phone number: PHONENUMBER",
      "Enter the amount: KAMOUNT",
      "Verify the recipient name shows as: ACCOUNTNAME",
      "Enter your PIN to confirm the transaction"
    ]
  }
]

IO.puts("Creating mobile money payment methods...")

Enum.each(methods, fn method ->
  case Content.get_mobile_money_payment_by_method(method.method_name) do
    nil ->
      # Convert steps list to map format for changeset
      steps_map = Enum.with_index(method.steps) |> Enum.into(%{}, fn {v, k} -> {to_string(k), v} end)
      attrs = Map.merge(method, %{"payment_steps" => steps_map}) |> Map.drop([:steps])

      case Content.create_mobile_money_payment(attrs) do
        {:ok, payment} ->
          IO.puts("  ✓ Created #{payment.method_name} payment method")

        {:error, changeset} ->
          IO.puts("  ✗ Failed to create #{method.method_name} payment method")
          IO.inspect(changeset.errors)
      end

    existing ->
      IO.puts("  ⊙ Payment method already exists: #{existing.method_name}")
  end
end)

IO.puts("Done!")

