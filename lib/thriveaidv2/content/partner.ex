defmodule Thriveaidv2.Content.Partner do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "partners" do
    field :name, :string
    field :logo_path, :string
    field :website_url, :string
    field :display_order, :integer, default: 0
    field :is_active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(partner, attrs) do
    # display_order is not in the cast list, so it won't be editable
    # Existing partners keep their current value, new partners get default: 0 from schema
    partner
    |> cast(attrs, [:name, :logo_path, :website_url, :is_active])
    |> validate_required([:name, :logo_path])
    |> validate_length(:name, max: 255)
    |> validate_length(:website_url, max: 500)
    |> validate_url_format(:website_url)
  end

  defp validate_url_format(changeset, field) do
    url = get_field(changeset, field)

    if is_nil(url) or url == "" do
      changeset
    else
      if String.match?(url, ~r/^https?:\/\/.+/) do
        changeset
      else
        add_error(changeset, field, "must be a valid URL starting with http:// or https://")
      end
    end
  end
end

