defmodule Thriveaidv2Web.TextHelpers do
  @moduledoc false

  import Phoenix.HTML

  @html_tag_re ~r/<\s*\/?\s*\w+[^>]*>/u

  @doc """
  Convert plain text to safe HTML (paragraphs + line breaks).
  """
  def text_to_html(nil), do: raw("")

  def text_to_html(text) when is_binary(text) do
    trimmed = String.trim(text)

    # Backwards compatibility: older content may already be HTML.
    # We keep rendering it as HTML, but the admin forms will auto-convert to plain text on edit.
    if Regex.match?(@html_tag_re, trimmed) do
      raw(trimmed)
    else
      escaped =
        trimmed
        |> html_escape()
        |> safe_to_string()

      html =
        escaped
        |> String.replace(~r/\R{2,}/u, "</p><p class=\"mb-4\">")
        |> String.replace(~r/\R/u, "<br/>")

      raw("<p class=\"mb-4\">#{html}</p>")
    end
  end

  @doc """
  Best-effort conversion from HTML to plain text (for admin editing).
  """
  def html_to_text(nil), do: ""

  def html_to_text(text) when is_binary(text) do
    trimmed = String.trim(text)

    if Regex.match?(@html_tag_re, trimmed) do
      trimmed
      |> String.replace(~r/<\s*br\s*\/?\s*>/iu, "\n")
      |> String.replace(~r/<\s*\/\s*(p|div|h\d|li)\s*>/iu, "\n\n")
      |> String.replace(~r/<[^>]*>/u, "")
      |> decode_basic_entities()
      |> String.replace(~r/\R{3,}/u, "\n\n")
      |> String.trim()
    else
      trimmed
    end
  end

  defp decode_basic_entities(text) do
    text
    |> String.replace("&nbsp;", " ")
    |> String.replace("&amp;", "&")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#34;", "\"")
    |> String.replace("&apos;", "'")
    |> String.replace("&#39;", "'")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&ldquo;", "\"")
    |> String.replace("&rdquo;", "\"")
    |> String.replace("&lsquo;", "'")
    |> String.replace("&rsquo;", "'")
    |> String.replace("&mdash;", "—")
  end
end


