defmodule Thriveaidv2.Inbox do
  @moduledoc """
  Inbox stores contact form submissions for admins to review.
  """

  import Ecto.Query, warn: false

  alias Swoosh.Email

  alias Thriveaidv2.Mailer
  alias Thriveaidv2.Repo
  alias Thriveaidv2.Inbox.ContactMessage

  def list_contact_messages do
    Repo.all(from m in ContactMessage, order_by: [asc: m.is_read, desc: m.inserted_at])
  end

  def unread_count do
    Repo.aggregate(from(m in ContactMessage, where: m.is_read == false), :count, :id)
  end

  def get_contact_message!(id), do: Repo.get!(ContactMessage, id)

  def create_contact_message(attrs \\ %{}) do
    %ContactMessage{}
    |> ContactMessage.changeset(attrs)
    |> Repo.insert()
  end

  def update_contact_message(%ContactMessage{} = msg, attrs) do
    msg
    |> ContactMessage.changeset(attrs)
    |> Repo.update()
  end

  def delete_contact_message(%ContactMessage{} = msg), do: Repo.delete(msg)

  def change_contact_message(%ContactMessage{} = msg, attrs \\ %{}) do
    ContactMessage.changeset(msg, attrs)
  end

  def reply_changeset(%ContactMessage{} = msg, attrs \\ %{}) do
    msg
    |> ContactMessage.changeset(attrs)
    |> Ecto.Changeset.validate_required([:reply_subject, :reply_body])
  end

  @doc """
  Send an email reply to a contact message and persist the reply.

  In dev, Swoosh.Local stores the email and you can view it at `/dev/mailbox`.
  """
  def reply_to_message(%ContactMessage{} = msg, attrs, admin_user) when is_map(attrs) do
    changeset =
      msg
      |> reply_changeset(attrs)
      |> Ecto.Changeset.put_change(:replied_at, DateTime.utc_now() |> DateTime.truncate(:second))
      |> Ecto.Changeset.put_change(:is_read, true)
      |> maybe_put_admin(admin_user)

    if changeset.valid? do
      subject = Ecto.Changeset.get_field(changeset, :reply_subject)
      body = Ecto.Changeset.get_field(changeset, :reply_body)

      email = build_reply_email(msg, subject, body)

      with {:ok, _} <- Mailer.deliver(email),
           {:ok, msg} <- Repo.update(changeset) do
        {:ok, msg}
      else
        {:error, reason} ->
          {:error, Ecto.Changeset.add_error(changeset, :reply_body, "could not send email (#{inspect(reason)})")}
      end
    else
      {:error, changeset}
    end
  end

  defp maybe_put_admin(changeset, %{id: id}) when is_integer(id) do
    Ecto.Changeset.put_change(changeset, :replied_by_admin_user_id, id)
  end

  defp maybe_put_admin(changeset, _), do: changeset

  defp build_reply_email(%ContactMessage{} = msg, subject, body) do
    from_cfg = Application.get_env(:thriveaidv2, :mailer_from, [])
    from_email = Keyword.get(from_cfg, :email, "no-reply@thriveaid.local")
    from_name = Keyword.get(from_cfg, :name, "ThriveAid")

    Email.new()
    |> Email.to({msg.name, msg.email})
    |> Email.from({from_name, from_email})
    |> Email.subject(subject)
    |> Email.text_body(body)
  end
end


