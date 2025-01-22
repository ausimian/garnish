defmodule Garnish.MixProject do
  use Mix.Project

  @version "0.2.0"
  @scm_url "https://github.com/ausimian/garnish"

  def project do
    [
      app: :garnish,
      description: description(),
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

  defp description, do: "A Terminal-UI framework for SSH-enabled applications."

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:typedstruct, "~> 0.5.0", runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:asciichart, "~> 1.0"}
    ]
  end

  defp package do
    [
      maintainers: ["ausimian"],
      licenses: ["MIT"],
      links: %{"GitHub" => @scm_url},
      files: ~w(lib CHANGELOG.md LICENSE.md mix.exs README.md .formatter.exs)
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
