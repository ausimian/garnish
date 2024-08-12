defmodule Garnish.MixProject do
  use Mix.Project

  @version "0.1.0"
  @scm_url "https://github.com/ausimian/garnish"

  def project do
    [
      app: :garnish,
      version: @version,
      elixir: "~> 1.15",
      source_url: @scm_url,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
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

  defp package do
    [
      maintainers: ["ausimian"],
      licenses: ["MIT"],
      links: %{"GitHub" => @scm_url},
      files:
        ~w(lib CHANGELOG.md LICENSE.md mix.exs README.md .formatter.exs)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ]
    ]
  end
end
