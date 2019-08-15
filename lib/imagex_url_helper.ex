defmodule ImagexUrlHelper do
  @moduledoc """
  Imagex helper functions for generating signed image urls.
  """

  def salt do 
    Application.get_env(:imagex_url_helper, :salt)
    |> Base.decode16!(case: :lower)
  end

  def key do
    Application.get_env(:imagex_url_helper, :key)
    |> Base.decode16!(case: :lower)
  end

  def prefix do
    Application.get_env(:imagex_url_helper, :prefix)
  end

  @doc """
  Builds and signs a url with given parameters

  ## Examples

      iex> ImagexUrlHelper.build_url("http://files.example.com/image.jpg", resize: 0, width: 300, height: 400)
      "http://img.example.com/KkoVXq-WlnBU4-KAERxGZ887..."

  """
  def build_url(nil, _), do: nil
  def build_url(img_url, opts) do
    path = build_path(img_url, opts)
    signature = gen_signature(path)

    Path.join([prefix(), signature, path])
  end

  defp build_path(img_url, opts) do
    resize_type = Keyword.get(opts, :resize_type, "fit")
    width = Keyword.get(opts, :width, 200)
    height = Keyword.get(opts, :height, 100)
    gravity = Keyword.get(opts, :gravity, "no")
    enlarge = Keyword.get(opts, :enlarge, 1)
    extension = Keyword.get(opts, :extension, "jpg")

    Path.join([
      "/",
      resize_type,
      to_string(width),
      to_string(height),
      gravity,
      to_string(enlarge),
      Base.url_encode64(img_url, padding: false) <> "." <> extension
    ])
  end

  defp gen_signature(path) do
    :sha256
    |> :crypto.hmac(key(), salt() <> path)
    |> Base.url_encode64(padding: false)
  end
  
end
