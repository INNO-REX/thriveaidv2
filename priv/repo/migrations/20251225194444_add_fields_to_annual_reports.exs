defmodule Thriveaidv2.Repo.Migrations.AddFieldsToAnnualReports do
  use Ecto.Migration

  def up do
    # Add columns only if they don't exist
    alter table(:annual_reports) do
      add_if_not_exists :year, :integer
      add_if_not_exists :title, :string
      add_if_not_exists :pdf_path, :string
      add_if_not_exists :description, :text
      add_if_not_exists :subtitle, :string
      add_if_not_exists :young_people_empowered, :integer
      add_if_not_exists :core_program_areas, :integer
      add_if_not_exists :volunteers_engaged, :integer
      add_if_not_exists :strategic_partners, :integer
      add_if_not_exists :program_highlights, :map, default: %{}
      add_if_not_exists :is_published, :boolean, default: false
      add_if_not_exists :published_at, :utc_datetime
    end

    # Create indexes if they don't exist
    create_if_not_exists index(:annual_reports, [:year])
    create_if_not_exists index(:annual_reports, [:is_published])
    
    # Create unique index if it doesn't exist
    execute """
    CREATE UNIQUE INDEX IF NOT EXISTS annual_reports_year_index ON annual_reports(year)
    """, """
    DROP INDEX IF EXISTS annual_reports_year_index
    """
  end

  def down do
    alter table(:annual_reports) do
      remove_if_exists :year, :integer
      remove_if_exists :title, :string
      remove_if_exists :pdf_path, :string
      remove_if_exists :description, :text
      remove_if_exists :subtitle, :string
      remove_if_exists :young_people_empowered, :integer
      remove_if_exists :core_program_areas, :integer
      remove_if_exists :volunteers_engaged, :integer
      remove_if_exists :strategic_partners, :integer
      remove_if_exists :program_highlights, :map
      remove_if_exists :is_published, :boolean
      remove_if_exists :published_at, :utc_datetime
    end

    drop_if_exists index(:annual_reports, [:year])
    drop_if_exists index(:annual_reports, [:is_published])
    
    execute """
    DROP INDEX IF EXISTS annual_reports_year_index
    """
  end
end
