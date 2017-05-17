defmodule MetaprogrammingWithoutMacrosExamples.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :metaprogramming_without_macros_examples,
     version: @version,
     elixir: "~> 1.4",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end
  def application do
    [applications: [:logger]]
  end
  defp deps do
    []
  end
  defp package do
    [maintainers: ["Ian Rumford"],
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/ianrumford/metaprogramming_without_macros_examples"}]
  end
  defp description do
    ~S"""
    metaprogramming_without_macros_examples: Examples for my blog post Metaprogramming Without Macros
    """
  end
end
