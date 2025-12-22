defmodule Thriveaidv2.Accounts.AdminUser do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @valid_permissions ~w(manage_admins manage_content manage_messages)

  schema "admin_users" do
    field :email, :string
    field :name, :string
    field :is_superadmin, :boolean, default: false
    field :permissions, {:array, :string}, default: []
    field :password, :string, virtual: true
    field :hashed_password, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :is_superadmin, :permissions, :password])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:email, max: 160)
    |> validate_subset(:permissions, @valid_permissions)
    |> maybe_hash_password()
    |> validate_required([:hashed_password])
    |> unique_constraint(:email)
  end

  defp maybe_hash_password(changeset) do
    password = get_change(changeset, :password)

    if is_binary(password) and String.length(password) >= 8 do
      put_change(changeset, :hashed_password, Pbkdf2.hash_pwd_salt(password))
    else
      changeset
      |> maybe_add_password_error(password)
    end
  end

  defp maybe_add_password_error(changeset, nil), do: changeset

  defp maybe_add_password_error(changeset, password) when is_binary(password) do
    if String.length(password) < 8 do
      add_error(changeset, :password, "should be at least 8 characters")
    else
      changeset
    end
  end
end


