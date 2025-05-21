defmodule Thriveaidv2Web.DonateLive do
  use Thriveaidv2Web, :live_view

  def mount(_params, _session, socket) do
    payment_methods = [
      %{
        id: "airtel",
        name: "Airtel Money",
        logo: "/images/payments/airtel-logo.jpg",
        color: "bg-red-600",
        number: "0970000000",
        description: "Fast and secure mobile money transfers"
      },
      %{
        id: "mtn",
        name: "MTN Money",
        logo: "/images/payments/mtn_logo.jpg",
        color: "bg-yellow-500",
        number: "0960000000",
        description: "Quick and reliable mobile payments"
      },
      %{
        id: "zamtel",
        name: "Zamtel Money",
        logo: "/images/payments/zamtel_logo.png",
        color: "bg-green-600",
        number: "0950000000",
        description: "Simple and convenient money transfers"
      },
      %{
        id: "visa",
        name: "Credit/Debit Card",
        logo: "/images/payments/visa1.png",
        color: "bg-blue-600",
        description: "Secure international card payments",
        card: true
      }
    ]

    {:ok,
     assign(socket,
       payment_methods: payment_methods,
       selected_method: nil,
       amount: nil,
       custom_amount: nil,
       donation_step: "amount", # amount, details, confirm
       donor: %{
         name: nil,
         email: nil,
         phone: nil,
         message: nil
       }
     )}
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
    donor = Map.merge(socket.assigns.donor, atomize_keys(params))
    {:noreply, assign(socket, donor: donor)}
  end

  defp atomize_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end
end
