defmodule Thriveaidv2Web.Uploads do
  @moduledoc false

  @uploads_dir "uploads"

  # Returns {public_path, disk_path}
  def persist_uploaded_file!(%{path: temp_path}, entry) do
    ext =
      entry.client_name
      |> Path.extname()
      |> String.downcase()

    filename = "#{Ecto.UUID.generate()}#{ext}"
    public_path = "/#{@uploads_dir}/#{filename}"

    priv_dir = :thriveaidv2 |> :code.priv_dir() |> to_string()
    disk_path = Path.join([priv_dir, "static", @uploads_dir, filename])

    disk_dir = Path.dirname(disk_path)
    File.mkdir_p!(disk_dir)
    File.cp!(temp_path, disk_path)

    {public_path, disk_path}
  end
end


