defmodule AyahDay.Logic do
  alias HTTPoison.Response

  @ayah_api_url "https://salamquran.com/fa/api/v6/aya/day"

  def main do
    get_ayah_for_this_day()
    |> get_verse_key()
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
end
