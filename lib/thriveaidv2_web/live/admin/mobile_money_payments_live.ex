defmodule Thriveaidv2Web.Admin.MobileMoneyPaymentsLive do
  use Thriveaidv2Web, :admin_live_view

  alias Thriveaidv2.Content
  alias Thriveaidv2.Content.MobileMoneyPayment

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(current_page: "admin")
     |> assign(admin_section: :mobile_money_payments)
     |> assign(page_title: "Mobile Money Payment Settings")
     |> assign(mobile_money_payments: Content.list_mobile_money_payments())
     |> assign(editing_payment: nil)
     |> assign(payment_steps: [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    payments = Content.list_mobile_money_payments()
    payments_with_logos = Enum.map(payments, fn payment ->
      Map.put(payment, :logo, get_payment_logo(payment.method_name))
    end)
    
    socket
    |> assign(:page_title, "Mobile Money Payment Settings")
    |> assign(:mobile_money_payments, payments_with_logos)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    payment = Content.get_mobile_money_payment!(id)
    steps = MobileMoneyPayment.steps_from_html(payment.payment_steps_html)
    steps = if length(steps) == 0, do: List.duplicate("", 6), else: steps

    socket
    |> assign(:page_title, "Edit #{String.capitalize(payment.method_name)} Payment Settings")
    |> assign(:editing_payment, payment)
    |> assign(:payment_steps, steps)
    |> assign_form(Content.change_mobile_money_payment(payment))
  end

  @impl true
  def handle_event("validate", all_params, socket) do
    steps_map = Map.get(all_params, "payment_steps", %{})
    current_steps = socket.assigns.payment_steps || []
    
    updated_steps = 
      if map_size(steps_map) > 0 do
        Enum.reduce(steps_map, current_steps, fn {idx_str, value}, acc ->
          idx = String.to_integer(idx_str)
          padded_acc = 
            if idx >= length(acc) do
              acc ++ List.duplicate("", idx - length(acc) + 1)
            else
              acc
            end
          List.replace_at(padded_acc, idx, value)
        end)
      else
        current_steps
      end
    
    params = Map.get(all_params, "mobile_money_payment", %{})
    changeset =
      Content.change_mobile_money_payment(socket.assigns.editing_payment, params)
      |> Map.put(:action, :validate)

    {:noreply, 
     socket
     |> assign(payment_steps: updated_steps)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("add-step", _params, socket) do
    current_steps = socket.assigns.payment_steps || []
    new_steps = current_steps ++ [""]
    {:noreply, assign(socket, payment_steps: new_steps)}
  end

  @impl true
  def handle_event("remove-step", %{"index" => index}, socket) do
    index = String.to_integer(index)
    current_steps = socket.assigns.payment_steps || []
    new_steps = List.delete_at(current_steps, index)
    {:noreply, assign(socket, payment_steps: new_steps)}
  end

  @impl true
  def handle_event("save", all_params, socket) do
    params = Map.get(all_params, "mobile_money_payment", %{})
    steps_map = Map.get(all_params, "payment_steps", %{})
    params = Map.put(params, "payment_steps", steps_map)

    case Content.update_mobile_money_payment(socket.assigns.editing_payment, params) do
      {:ok, payment} ->
        payment_steps = MobileMoneyPayment.steps_from_html(payment.payment_steps_html)
        payment_steps = if length(payment_steps) == 0, do: List.duplicate("", 6), else: payment_steps
        
        {:noreply,
         socket
         |> put_flash(:info, "#{String.capitalize(payment.method_name)} payment settings updated successfully")
         |> assign(mobile_money_payments: Content.list_mobile_money_payments())
         |> assign(editing_payment: nil)
         |> assign(payment_steps: payment_steps)
         |> push_navigate(to: ~p"/admin/mobile-money-payments")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("create-defaults", _params, socket) do
    # Create default mobile money payment methods if they don't exist
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

    Enum.each(methods, fn method ->
      case Content.get_mobile_money_payment_by_method(method.method_name) do
        nil ->
          steps_html = format_steps_for_method(method.steps)
          Content.create_mobile_money_payment(
            Map.merge(method, %{payment_steps_html: steps_html})
            |> Map.drop([:steps])
          )
        _ ->
          :ok
      end
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Default mobile money payment methods created")
     |> assign(mobile_money_payments: Content.list_mobile_money_payments())}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp format_steps_for_method(steps) when is_list(steps) do
    # Use the MobileMoneyPayment module's format_steps_as_html function
    steps_map = Enum.with_index(steps) |> Enum.into(%{}, fn {v, k} -> {to_string(k), v} end)
    
    case MobileMoneyPayment.changeset(%MobileMoneyPayment{}, %{"payment_steps" => steps_map}) do
      %Ecto.Changeset{changes: %{payment_steps_html: html}} -> html
      _ -> ""
    end
  end

  def get_payment_logo("airtel"), do: "/images/payments/airtel-logo.jpg"
  def get_payment_logo("mtn"), do: "/images/payments/mtn_logo.jpg"
  def get_payment_logo("zamtel"), do: "/images/payments/zamtel_logo.png"
  def get_payment_logo(_), do: "/images/payments/default.png"
end

