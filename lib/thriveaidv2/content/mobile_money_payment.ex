defmodule Thriveaidv2.Content.MobileMoneyPayment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "mobile_money_payments" do
    field :method_name, :string  # "airtel", "mtn", "zamtel"
    field :phone_number, :string
    field :account_name, :string
    field :payment_steps_html, :string
    field :payment_steps, {:array, :string}, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mobile_money_payment, attrs) do
    attrs = convert_steps_to_html(attrs)
    
    mobile_money_payment
    |> cast(attrs, [:method_name, :phone_number, :account_name, :payment_steps_html])
    |> validate_required([:method_name, :phone_number, :account_name, :payment_steps_html])
    |> validate_length(:phone_number, max: 50)
    |> validate_length(:account_name, max: 255)
    |> validate_length(:method_name, max: 50)
    |> unique_constraint(:method_name)
  end

  defp convert_steps_to_html(%{"payment_steps" => steps} = attrs) when is_map(steps) do
    # Convert map of steps (like %{"0" => "step 1", "1" => "step 2"}) to HTML
    step_list = 
      steps
      |> Enum.sort_by(fn {k, _} -> String.to_integer(k) end)
      |> Enum.map(fn {_, v} -> String.trim(v) end)
      |> Enum.reject(&(&1 == ""))
    
    html = format_steps_as_html(step_list)
    Map.put(attrs, "payment_steps_html", html)
  end

  defp convert_steps_to_html(attrs), do: attrs

  defp format_steps_as_html(steps) when is_list(steps) do
    steps_html = 
      steps
      |> Enum.with_index(1)
      |> Enum.map(fn {step, index} ->
        # Allow placeholders and basic formatting, but escape dangerous HTML
        formatted_step = format_step_text(step)
        """
        <li class="flex items-start">
          <span class="flex-shrink-0 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center text-white font-semibold mr-3 mt-0.5">#{index}</span>
          <span>#{formatted_step}</span>
        </li>
        """
      end)
      |> Enum.join("\n")
    
    "<ol class=\"space-y-3 text-gray-300\">\n#{steps_html}\n</ol>"
  end

  defp format_steps_as_html(_), do: ""

  defp format_step_text(text) when is_binary(text) do
    # First escape the text to prevent XSS
    escaped = escape_html_basic(text)
    
    # Then replace placeholders with HTML tags (these are safe since we control them)
    # We need to replace the escaped versions of the placeholders
    escaped
    |> String.replace("PHONENUMBER", "<strong class=\"text-red-400\">PHONENUMBER</strong>")
    |> String.replace("KAMOUNT", "<strong class=\"text-red-400\">KAMOUNT</strong>")
    |> String.replace("ACCOUNTNAME", "<strong class=\"text-white\">ACCOUNTNAME</strong>")
  end

  defp escape_html_basic(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end

  def steps_from_html(nil), do: []
  def steps_from_html(html) when is_binary(html) do
    # Extract text from <li> tags, removing the numbered span and restoring placeholders
    Regex.scan(~r/<li[^>]*>\s*<span[^>]*>[0-9]+<\/span>\s*<span>(.*?)<\/span>\s*<\/li>/s, html)
    |> Enum.map(fn [_, text] -> 
      text
      |> String.replace("&amp;", "&")
      |> String.replace("&lt;", "<")
      |> String.replace("&gt;", ">")
      |> String.replace("&quot;", "\"")
      |> String.replace("&#39;", "'")
      |> String.replace(~r/<strong[^>]*>PHONENUMBER<\/strong>/, "PHONENUMBER")
      |> String.replace(~r/<strong[^>]*>KAMOUNT<\/strong>/, "KAMOUNT")
      |> String.replace(~r/<strong[^>]*>ACCOUNTNAME<\/strong>/, "ACCOUNTNAME")
      |> String.replace(~r/<[^>]+>/, "")  # Remove any remaining HTML tags
      |> String.trim()
    end)
  end
end

