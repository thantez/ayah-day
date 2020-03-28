defmodule AyahDay.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias AyahDay.Logic

  import Scenic.Primitives

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    IO.puts("hi there is home")
    main_pid = spawn(&Logic.main/0)
    send(main_pid, {:start, self()})

    receive do
      {:done, verse_key} ->
        IO.puts("I recived verse_key" <> verse_key)

        image_path =
          :code.priv_dir(:ayah_day) |> Path.join("/static/image/" <> verse_key <> ".png")

        image_hash = Scenic.Cache.Support.Hash.file!(image_path, :sha)

        graph =
          Graph.build()
          |> group(fn g ->
            g
            |> rect({800, 800}, fill: :white)
            |> rect({800, 800}, fill: {:image, {image_hash, 0, 0, 800, 800, 0, 255}})
          end)

        Scenic.Cache.Static.Texture.load(image_path, image_hash)
        {:ok, :show_img, push: graph}
    end
  end
end
