defmodule AyahDay.Logic do
  alias HTTPoison.Response

  @ayah_api_url "https://salamquran.com/fa/api/v6/aya/day"
  @pic_source "http://www.everyayah.com/data/images_png/"
  @sound_source "http://www.everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps/"
  @translate_source "https://dl.salamquran.com/ayat/makarem.fa.kabiri-translation-16/"
  @tafsir_source "https://dl.salamquran.com/ayat/qaraati.fa.qaraati-tafsir-16/"
  @priv_dir :code.priv_dir(:ayah_day)

  def main do
    get_ayah_for_this_day()
    |> get_verse_key()
    |> get_and_cache_ayah_content(&img_link_creator/1, &img_path_creator/1)
    |> get_and_cache_ayah_content(&sound_link_creator/1, &sound_path_creator/1)
    |> get_and_cache_ayah_content(&translate_link_creator/1, &translate_path_creator/1)
    |> get_and_cache_ayah_content(&tafsir_link_creator/1, &tafsir_path_creator/1)
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

  def get_and_cache_ayah_content(verse_key, link_creator, path_creator) do
    get_ayah_content(verse_key, link_creator)
    |> cache_content(verse_key, path_creator)

    verse_key
  end

  def get_ayah_content(verse_key, link_creator) do
    verse_key
    |> link_creator.()
    |> HTTPoison.get()
    |> export_body()
  end

  def cache_content(image_bin, verse_key, path_creator) do
    verse_key
    |> path_creator.()
    |> File.write!(image_bin)
  end

  def export_body({:ok, %Response{status_code: 200, body: body}}) do
    body
  end

  def export_body(param), do: IO.puts("Json is not true #{IO.inspect(param)}")

  def img_link_creator(verse_key) do
    @pic_source <> verse_key <> ".png"
  end

  def img_path_creator(verse_key) do
    @priv_dir
    |> Path.join("/static/image/" <> verse_key <> ".png")
  end

  def sound_link_creator(verse_key) do
    verse_key_with_zero = zero_to_verse(verse_key)
    @sound_source <> verse_key_with_zero <> ".mp3"
  end

  def sound_path_creator(verse_key) do
    @priv_dir
    |> Path.join("/static/sound/" <> verse_key <> ".mp3")
  end

  def translate_link_creator(verse_key) do
    verse_key_with_zero = zero_to_verse(verse_key)
    @translate_source <> verse_key_with_zero <> ".mp3"
  end

  def translate_path_creator(verse_key) do
    @priv_dir
    |> Path.join("/static/translate/" <> verse_key <> ".mp3")
  end

  def tafsir_link_creator(verse_key) do
    verse_key_with_zero = zero_to_verse(verse_key)
    @tafsir_source <> verse_key_with_zero <> ".mp3"
  end

  def tafsir_path_creator(verse_key) do
    @priv_dir
    |> Path.join("/static/tafsir/" <> verse_key <> ".mp3")
  end

  def zero_to_verse(verse_key) do
    verse_key
    |> String.split("_")
    |> Enum.map(fn key -> String.pad_leading(key, 3, "0") end)
    |> Enum.join("")
  end
end
