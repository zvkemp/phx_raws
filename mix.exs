defmodule PhxRaws.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phx_raws,
      version: "0.1.0",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: [
        {:plug, "~> 1.4.3"},
        {:phoenix, "~> 1.3.0"},
        {:socket, "~> 0.3.13", only: :test},
        {:cowboy, "~> 1.0", only: :test}
      ]
    ]
  end
end
