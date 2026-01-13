defmodule Thriveaidv2.Content.AnnualReport do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "annual_reports" do
    field :year, :integer
    field :title, :string
    field :pdf_path, :string
    field :description, :string
    field :subtitle, :string
    # Statistics fields
    field :young_people_empowered, :integer
    field :core_program_areas, :integer
    field :volunteers_engaged, :integer
    field :strategic_partners, :integer
    # Program highlights
    field :program_highlights, :map, default: %{}
    field :is_published, :boolean, default: false
    field :published_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(annual_report, attrs) do
    annual_report
    |> cast(attrs, [
      :year,
      :title,
      :pdf_path,
      :description,
      :subtitle,
      :young_people_empowered,
      :core_program_areas,
      :volunteers_engaged,
      :strategic_partners,
      :program_highlights,
      :is_published,
      :published_at
    ])
    |> validate_required([:year, :title])
    |> validate_length(:title, max: 255)
    |> validate_length(:subtitle, max: 255)
    |> validate_number(:year, greater_than: 2000, less_than: 2100)
    |> maybe_put_published_at()
  end

  defp maybe_put_published_at(changeset) do
    is_published = get_field(changeset, :is_published)
    published_at = get_field(changeset, :published_at)

    cond do
      is_published == true && is_nil(published_at) ->
        put_change(changeset, :published_at, DateTime.truncate(DateTime.utc_now(), :second))

      is_published == false ->
        put_change(changeset, :published_at, nil)

      true ->
        changeset
    end
  end
end

