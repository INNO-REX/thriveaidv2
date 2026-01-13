alias Thriveaidv2.Content
alias Thriveaidv2.Content.MobileMoneyPayment

# Fix payment steps HTML for all methods
methods = ["airtel", "mtn", "zamtel"]

IO.puts("Fixing payment steps HTML...")

Enum.each(methods, fn method_name ->
  case Content.get_mobile_money_payment_by_method(method_name) do
    nil ->
      IO.puts("  ⊙ #{method_name} not found")
      
    payment ->
      # Get current steps
      steps = MobileMoneyPayment.steps_from_html(payment.payment_steps_html)
      
      if length(steps) > 0 do
        # Re-format the steps using the updated format function
        steps_map = Enum.with_index(steps) |> Enum.into(%{}, fn {v, k} -> {to_string(k), v} end)
        attrs = %{"payment_steps" => steps_map}
        
        case Content.update_mobile_money_payment(payment, attrs) do
          {:ok, _} ->
            IO.puts("  ✓ Fixed #{method_name} payment steps")
            
          {:error, changeset} ->
            IO.puts("  ✗ Failed to fix #{method_name}")
            IO.inspect(changeset.errors)
        end
      else
        IO.puts("  ⊙ #{method_name} has no steps to fix")
      end
  end
end)

IO.puts("Done!")

