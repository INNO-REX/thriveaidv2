defmodule Thriveaidv2.Inbox.ContactMessage do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "contact_messages" do
    field :name, :string
    field :email, :string
    field :subject, :string
    field :message, :string
    field :is_read, :boolean, default: false
    field :reply_subject, :string
    field :reply_body, :string
    field :replied_at, :utc_datetime
    field :replied_by_admin_user_id, :id

    timestamps(type: :utc_datetime)
  end

  def changeset(contact_message, attrs) do
    contact_message
    |> cast(attrs, [:name, :email, :subject, :message, :is_read, :reply_subject, :reply_body, :replied_at, :replied_by_admin_user_id])
    |> validate_required([:name, :email, :subject, :message])
    |> validate_length(:name, max: 120)
    |> validate_length(:email, max: 160)
    |> validate_length(:subject, max: 200)
    |> validate_length(:message, max: 4000)
    |> validate_length(:reply_subject, max: 200)
    |> validate_length(:reply_body, max: 4000)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
  end
end


