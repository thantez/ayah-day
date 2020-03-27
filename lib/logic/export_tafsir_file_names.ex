defmodule AyahDay.Logic.ExportTafsirFileNames do
  alias HTTPoison.Response

  @tafsir_source "https://dl.salamquran.com/ayat/qaraati.fa.qaraati-tafsir-16/"

  def main do
    get_list(@tafsir_source)
    |> Enum.map(&make_file_link(&1, &1))
    |> List.flatten()
    |> Enum.into(%{})
  end

  def get_list(source) do
    body =
      source
      |> HTTPoison.get()
      |> get_body()

    Regex.scan(~r/[0-9]+(-?([0-9]+))\.mp3/, body)
    |> Enum.dedup()
    |> Enum.map(fn matches -> Enum.at(matches, 0) end)
  end

  def get_body({:ok, %Response{body: body}}) do
    body
  end

  def make_file_link([first, last], link) do
    surah =
      first
      |> String.slice(0..2)

    first_id =
      first
      |> make_id()

    last_id =
      (surah <> last)
      |> make_id()

    first_id..last_id
    |> Enum.map(fn id -> Integer.to_string(id) end)
    |> Enum.map(fn file -> String.pad_leading(file, 6, "0") <> ".mp3" end)
    |> Enum.map(&make_file_link(&1, link))
  end

  def make_file_link([file_id], link) do
    file =
      file_id
      |> String.to_atom()

    {file, @tafsir_source <> link}
  end

  def make_file_link(file, link) do
    file
    |> String.split("-")
    |> make_file_link(link)
  end

  def make_id(str) do
    str
    |> remove_mp3()
    |> String.to_integer()
  end

  def remove_mp3(str) do
    str
    |> String.replace_suffix(".mp3", "")
  end
end
