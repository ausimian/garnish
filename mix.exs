defmodule Garnish.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :garnish,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ssh]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:typed_struct, "~> 0.3.0", runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:asciichart, "~> 1.0"}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md"
      ]
    ]
  end
end
