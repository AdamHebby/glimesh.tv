defmodule Glimesh.Avatar do
  @moduledoc false

  use Waffle.Definition

  # Include ecto support (requires package waffle_ecto installed):
  use Waffle.Ecto.Definition

  @versions [:original]

  def acl(:original, _), do: :public_read

  # Whitelist file extensions:
  def validate({file, _}) do
    Glimesh.FileValidation.validate(file, [:png, :jpg])
  end

  # Define a thumbnail transformation:
  def transform(:original, _) do
    {:convert, "-strip -thumbnail 200x200^ -gravity center -extent 200x200 -format png", :png}
  end

  # Override the persisted filenames:
  def filename(_version, {_file, scope}) do
    scope.username
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, _scope}) do
    "uploads/avatars"
  end

  def s3_object_headers(_version, {file, _scope}) do
    [
      cache_control: "public, max-age=604800",
      content_type: MIME.from_path(file.file_name)
    ]
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(_version, scope) do
    hash = :crypto.hash(:md5, String.downcase(scope.email)) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}?s=200&d=wavatar"
  end
end
