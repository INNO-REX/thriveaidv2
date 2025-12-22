defmodule Thriveaidv2.Accounts do
  @moduledoc """
  Minimal admin authentication (session-based).
  """

  import Ecto.Query, warn: false

  alias Thriveaidv2.Repo
  alias Thriveaidv2.Accounts.AdminUser

  def get_admin_user(id) when is_integer(id), do: Repo.get(AdminUser, id)
  def get_admin_user!(id), do: Repo.get!(AdminUser, id)

  def get_admin_user_by_email(email) when is_binary(email) do
    Repo.one(from u in AdminUser, where: u.email == ^email)
  end

  def list_admin_users do
    Repo.all(from u in AdminUser, order_by: [asc: u.email])
  end

  def count_admins_with_permission(permission) when is_binary(permission) do
    Repo.aggregate(from(u in AdminUser, where: ^permission in u.permissions), :count, :id)
  end

  def has_permission?(%AdminUser{} = user, permission) when is_binary(permission) do
    permission in (user.permissions || [])
  end

  def create_admin_user(attrs \\ %{}) do
    %AdminUser{}
    |> AdminUser.changeset(attrs)
    |> Repo.insert()
  end

  def update_admin_user(%AdminUser{} = user, attrs) do
    user
    |> AdminUser.changeset(attrs)
    |> Repo.update()
  end

  def delete_admin_user(%AdminUser{} = user), do: Repo.delete(user)

  def change_admin_user(%AdminUser{} = user, attrs \\ %{}) do
    AdminUser.changeset(user, attrs)
  end

  @doc """
  Authenticate an admin user by email + password.
  """
  def authenticate_admin(email, password)
      when is_binary(email) and is_binary(password) do
    with %AdminUser{} = user <- get_admin_user_by_email(email),
         true <- Pbkdf2.verify_pass(password, user.hashed_password) do
      {:ok, user}
    else
      _ -> {:error, :invalid_credentials}
    end
  end
end


