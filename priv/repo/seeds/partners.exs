alias Thriveaidv2.Repo
alias Thriveaidv2.Content.Partner

# Create the original partners
partners = [
  %{
    name: "ThriveAid",
    logo_path: "/images/logo-header-4.png",
    website_url: nil,
    display_order: 1,
    is_active: true
  },
  %{
    name: "Axis",
    logo_path: "/images/axis.png",
    website_url: nil,
    display_order: 2,
    is_active: true
  },
  %{
    name: "Friends of Homabay",
    logo_path: "/images/FOH.png",
    website_url: nil,
    display_order: 3,
    is_active: true
  }
]

IO.puts("Creating partners...")

Enum.each(partners, fn partner_attrs ->
  case Repo.get_by(Partner, logo_path: partner_attrs[:logo_path]) do
    nil ->
      case Repo.insert(Partner.changeset(%Partner{}, partner_attrs)) do
        {:ok, partner} ->
          IO.puts("  ✓ Created partner: #{partner.name}")

        {:error, changeset} ->
          IO.puts("  ✗ Failed to create partner: #{partner_attrs[:name]}")
          IO.inspect(changeset.errors)
      end

    existing ->
      IO.puts("  ⊙ Partner already exists: #{existing.name}")
  end
end)

IO.puts("Done!")

