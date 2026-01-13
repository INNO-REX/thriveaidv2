defmodule Thriveaidv2.Content.Donation do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "donations" do
    field :donor_name, :string
    field :donor_email, :string
    field :donor_phone, :string
    field :donor_message, :string
    field :amount, :integer
    field :payment_method, :string
    field :status, :string, default: "pending"  # pending, completed, failed

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(donation, attrs) do
    donation
    |> cast(attrs, [:donor_name, :donor_email, :donor_phone, :donor_message, :amount, :payment_method, :status])
    |> validate_required([:donor_name, :donor_email, :amount, :payment_method])
    |> validate_length(:donor_name, max: 255)
    |> validate_length(:donor_email, max: 255)
    |> validate_length(:donor_phone, max: 50)
    |> validate_length(:donor_message, max: 1000)
    |> validate_length(:payment_method, max: 50)
    |> validate_number(:amount, greater_than: 0)
    |> validate_format(:donor_email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
  end
end

