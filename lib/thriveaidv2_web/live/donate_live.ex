defmodule Thriveaidv2Web.DonateLive do
  use Thriveaidv2Web, :live_view

  alias Thriveaidv2.Content

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(donation_completed: false)
     |> load_payment_methods()}
  end

  defp load_payment_methods(socket) do
    # Fetch all mobile money payment methods from database
    mobile_money_payments = Content.list_mobile_money_payments()
    
    # Build payment methods list with dynamic mobile money methods
    mobile_money_methods = 
      mobile_money_payments
      |> Enum.map(fn payment ->
        method_config = get_method_config(payment.method_name)
        Map.merge(method_config, %{
          id: payment.method_name,
          number: payment.phone_number,
          account_name: payment.account_name,
          payment_steps_html: payment.payment_steps_html
        })
      end)
    
    # Add card payment method (static)
    card_method = %{
      id: "card",
      name: "Credit/Debit Card",
      logo: "/images/payments/visa1.png",
      color: "bg-blue-600",
      card: true,
      description: "Secure online payment"
    }
    
    payment_methods = mobile_money_methods ++ [card_method]

    assign(socket,
      payment_methods: payment_methods,
      selected_method: nil,
      amount: nil,
      custom_amount: nil,
      donation_step: "amount", # amount, details, confirm, thank_you
      donor: %{
        name: nil,
        email: nil,
        phone: nil,
        message: nil
      }
    )
  end

  def handle_event("select-amount", %{"amount" => amount}, socket) do
    {amount, _} = Integer.parse(amount)
    {:noreply, assign(socket, amount: amount, custom_amount: nil)}
  end

  def handle_event("set-custom-amount", %{"amount" => amount}, socket) do
    case Integer.parse(amount) do
      {parsed_amount, _} ->
        {:noreply, assign(socket, amount: parsed_amount, custom_amount: parsed_amount)}
      :error ->
        {:noreply, socket}
    end
  end

  def handle_event("select-payment-method", %{"method" => method_id}, socket) do
    method = Enum.find(socket.assigns.payment_methods, &(&1.id == method_id))
    {:noreply, assign(socket, selected_method: method)}
  end

  def handle_event("next-step", _params, %{assigns: %{donation_step: "amount"}} = socket) do
    if socket.assigns.amount && socket.assigns.amount > 0 do
      {:noreply, assign(socket, donation_step: "details")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("next-step", _params, %{assigns: %{donation_step: "details"}} = socket) do
    {:noreply, assign(socket, donation_step: "confirm")}
  end

  def handle_event("prev-step", _params, %{assigns: %{donation_step: "details"}} = socket) do
    {:noreply, assign(socket, donation_step: "amount")}
  end

  def handle_event("prev-step", _params, %{assigns: %{donation_step: "confirm"}} = socket) do
    {:noreply, assign(socket, donation_step: "details")}
  end

  def handle_event("update-donor", params, socket) do
    # Extract form values - params come directly from the form inputs
    current_donor = socket.assigns.donor || %{name: nil, email: nil, phone: nil, message: nil}
    
    updated_donor = %{
      name: params["name"] || current_donor.name || "",
      email: params["email"] || current_donor.email || "",
      phone: params["phone"] || current_donor.phone || "",
      message: params["message"] || current_donor.message || ""
    }
    
    {:noreply, assign(socket, donor: updated_donor)}
  end

  def handle_event("complete-donation", _params, socket) do
    # Validate required fields
    cond do
      is_nil(socket.assigns.selected_method) ->
        {:noreply,
         socket
         |> put_flash(:error, "Please select a payment method.")}

      is_nil(socket.assigns.amount) || socket.assigns.amount <= 0 ->
        {:noreply,
         socket
         |> put_flash(:error, "Please enter a valid donation amount.")}

      is_nil(socket.assigns.donor.name) || socket.assigns.donor.name == "" ->
        {:noreply,
         socket
         |> put_flash(:error, "Please enter your name.")}

      is_nil(socket.assigns.donor.email) || socket.assigns.donor.email == "" ->
        {:noreply,
         socket
         |> put_flash(:error, "Please enter your email address.")}

      true ->
        # Save donation to database
        payment_method_id = 
          if Map.get(socket.assigns.selected_method, :id) do
            socket.assigns.selected_method.id
          else
            "unknown"
          end

        donation_attrs = %{
          "donor_name" => socket.assigns.donor.name || "",
          "donor_email" => socket.assigns.donor.email || "",
          "donor_phone" => socket.assigns.donor.phone || "",
          "donor_message" => socket.assigns.donor.message || "",
          "amount" => socket.assigns.amount,
          "payment_method" => payment_method_id,
          "status" => "pending"
        }

        case Content.create_donation(donation_attrs) do
          {:ok, _donation} ->
            # Show thank you page
            {:noreply,
             socket
             |> assign(donation_step: "thank_you")
             |> assign(donation_completed: true)}

          {:error, changeset} ->
            error_message = 
              case changeset.errors do
                [] -> "There was an error processing your donation. Please try again."
                errors -> 
                  errors
                  |> Enum.map(fn {field, {message, _}} -> "#{field}: #{message}" end)
                  |> Enum.join(", ")
              end

            {:noreply,
             socket
             |> put_flash(:error, error_message)}
        end
    end
  end

  def handle_event("start-new-donation", _params, socket) do
    # Reset to start a new donation
    {:noreply,
     socket
     |> assign(donation_step: "amount")
     |> assign(selected_method: nil)
     |> assign(amount: nil)
     |> assign(custom_amount: nil)
     |> assign(donation_completed: false)
     |> assign(donor: %{
       name: nil,
       email: nil,
       phone: nil,
       message: nil
     })}
  end


  defp get_method_config("airtel") do
    %{
      name: "Airtel Money",
      logo: "/images/payments/airtel-logo.jpg",
      color: "bg-red-600",
      description: "Mobile money payment"
    }
  end

  defp get_method_config("mtn") do
    %{
      name: "MTN Mobile Money",
      logo: "/images/payments/mtn_logo.jpg",
      color: "bg-yellow-600",
      description: "Mobile money payment"
    }
  end

  defp get_method_config("zamtel") do
    %{
      name: "Zamtel Kwacha",
      logo: "/images/payments/zamtel_logo.png",
      color: "bg-blue-600",
      description: "Mobile money payment"
    }
  end

  defp get_method_config(_), do: %{name: "Mobile Money", logo: "", color: "bg-gray-600", description: "Mobile money payment"}
end

