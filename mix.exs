defmodule AdventOfCode2024.MixProject do
  use Mix.Project

  def project do
    [
      app: :advent_of_code_2024,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nx, "~> 0.9.2"},
      {:csv, "~> 2.4"},
      {:matrix, git: "git@github.com:fabio-t/elixir-matrix.git", branch: "master"},
      {:benchee, "~> 1.0"},
      {:memoize, "~> 1.4.3"},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
