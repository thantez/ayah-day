defmodule AyahDay.MixProject do
  use Mix.Project

  def project do
    [
      app: :ayah_day,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {AyahDay, []},
      extra_applications: [:httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10", targets: :host},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:mogrify, "~> 0.7.3"},
      {:font_metrics, "~> 0.3.1"}
    ]
  end
end
