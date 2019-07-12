defmodule ImagexUrlHelper do
  @moduledoc """
  Documentation for ImagexUrlHelper.
  """

  @salt Application.get_env(:imagex_url_helper, :salt)
  def salt, do: Base.decode16!(@salt, case: :lower)

  @key Application.get_env(:imagex_url_helper, :key)
  def key, do: Base.decode16!(@key, case: :lower)

  @prefix Application.get_env(:imagex_url_helper, :prefix)
  def prefix, do: @prefix

  @doc """
  Builds and signs a url with given parameters

  ## Examples

      iex> ImagexUrlHelper.build_url("http://files.example.com/image.jpg", %{resize: 0, width: 300, height: 400})
      "http://img.example.com/KkoVXq-WlnBU4-KAERxGZ887..."

  """
  def build_url(img_url, opts) do
    path = build_path(img_url, opts)
    signature = gen_signature(path)

    Path.join([prefix, signature, path])
  end

  defp build_path(img_url, opts) do
    Path.join([
      "/",
      opts.resize,
      to_string(opts.width),
      to_string(opts.height),
      opts.gravity,
      to_string(opts.enlarge),
      Base.url_encode64(img_url, padding: false) <> "." <> opts.extension
    ])
  end

  defp gen_signature(path) do
    :sha256
    |> :crypto.hmac(key, salt <> path)
    |> Base.url_encode64(padding: false)
  end
  
end
