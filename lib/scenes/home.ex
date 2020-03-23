defmodule AyahDay.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph

  import Scenic.Primitives

  # import Scenic.Components

  @image_path :code.priv_dir(:ayah_day) |> Path.join('/static/img.png')
  @image_hash Scenic.Cache.Support.Hash.file!(@image_path, :sha)

  @graph Graph.build()
         |> group(fn g ->
           g
           |> rect({600, 500}, fill: :white)
           |> rect({600, 500}, fill: {:image, {@image_hash, 0, 0, 600, 500, 0, 255}})
         end)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    Scenic.Cache.Static.Texture.load(@image_path, @image_hash)
    {:ok, :show_img, push: @graph}
  end
end
