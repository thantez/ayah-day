defmodule AyahDay.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias AyahDay.Logic

  import Scenic.Primitives

  @priv_dir :code.priv_dir(:ayah_day)

  @images_path (@priv_dir |> Path.join("/static/image/")) <> "/"
  @sounds_path (@priv_dir |> Path.join("/static/sound/")) <> "/"
  @tafsirs_path (@priv_dir |> Path.join("/static/tafsir/")) <> "/"
  @translates_path (@priv_dir |> Path.join("/static/translate/")) <> "/"

  @font_path :code.priv_dir(:ayah_day) |> Path.join("/static/Vazir.ttf")
  @font_hash Scenic.Cache.Support.Hash.file!(@font_path, :sha)

  # ============================================================================
  # setup
  def play_sounds() do
    receive do
      {:sound, verse_key} ->
        System.cmd("play", [@sounds_path <> verse_key <> ".mp3"])
        System.cmd("play", [@translates_path <> verse_key <> ".mp3"])
        System.cmd("play", [@tafsirs_path <> verse_key <> ".mp3"])
    end
  end

  # --------------------------------------------------------
  def init(_, _opts) do
    IO.puts("hi there is home")
    logic_pid = spawn(&Logic.main/0)
    send(logic_pid, {:start, self()})
    play_pid = spawn(&play_sounds/0)

    receive do
      {:done, {verse_key, translate}} ->
        IO.puts("I recived " <> verse_key <> "'s translate: " <> translate)

        send(play_pid, {:sound, verse_key})

        image_path = @images_path <> verse_key <> ".png"
        image_hash = Scenic.Cache.Support.Hash.file!(image_path, :sha)

        Scenic.Cache.Static.Font.load(@font_path, @font_hash)
        Scenic.Cache.Static.Texture.load(image_path, image_hash)

        graph =
          Graph.build()
          |> group(fn g ->
            g
            |> text(translate, t: {0, 700}, fill: :white, text_align: :center, font: @font_hash)
            |> rect({800, 605}, fill: :white)
            |> rect({800, 605}, fill: {:image, {image_hash, 0, 0, 800, 605, 0, 255}})
          end)

        {:ok, :show_img, push: graph}
    end
  end
end
