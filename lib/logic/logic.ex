defmodule AyahDay.Logic do
  alias HTTPoison.Response

  @ayah_api_url "https://salamquran.com/fa/api/v6/aya/day"
  @pic_source "http://www.everyayah.com/data/images_png/"
  @priv_dir :code.priv_dir(:ayah_day)

  def main do
    get_ayah_for_this_day()
    |> get_verse_key()
    |> get_and_cache_ayah_pic()

    # |> get_and_cache_ayah_sound()
  end

  def get_ayah_for_this_day do
    @ayah_api_url
    |> HTTPoison.get()
    |> export_json()
  end

  def export_json({:ok, %Response{status_code: 200, body: body}}) do
    Jason.decode!(body)
  end

  def export_json(param), do: IO.puts("Json is not true #{IO.inspect(param)}")

  def get_verse_key(%{"ok" => true, "result" => %{"aya" => ayah, "sura" => surah}}) do
    "#{surah}_#{ayah}"
  end

  def get_verse_key(param), do: IO.puts("Json is not true #{IO.inspect(param)}")

  def get_and_cache_ayah_pic(verse_key) do
    get_ayah_content(verse_key, &pic_link_creator/1)
    |> cache_content(verse_key, &image_path/1)
  end

  def get_ayah_content(verse_key, link_creator) do
    verse_key
    |> link_creator.()
    |> HTTPoison.get()
    |> export_body()
  end

  def pic_link_creator(verse_key) do
    @pic_source <> verse_key <> ".png"
  end

  def export_body({:ok, %Response{status_code: 200, body: body}}) do
    body
  end

  def export_body(param), do: IO.puts("Json is not true #{IO.inspect(param)}")

  def cache_content(image_bin, verse_key, path_creator) do
    verse_key
    |> path_creator.()
    |> File.write!(image_bin)
  end

  def image_path(verse_key) do
    @priv_dir
    |> Path.join("/static/" <> verse_key <> ".png")
  end
end
